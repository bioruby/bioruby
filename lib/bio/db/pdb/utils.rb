#
# bio/db/pdb/utils.rb - Utility modules for PDB
#
#   Copyright (C) 2004 Alex Gutteridge <alexg@ebi.ac.uk>
#   Copyright (C) 2004 GOTO Naohisa <ngoto@gen-info.osaka-u.ac.jp>
#
#  This library is free software; you can redistribute it and/or
#  modify it under the terms of the GNU Lesser General Public
#  License as published by the Free Software Foundation; either
#  version 2 of the License, or (at your option) any later version.
#
#  This library is distributed in the hope that it will be useful,
#  but WITHOUT ANY WARRANTY; without even the implied warranty of
#  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
#  Lesser General Public License for more details.
#
#  You should have received a copy of the GNU Lesser General Public
#  License along with this library; if not, write to the Free Software
#  Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307  USA
#
#  $Id: utils.rb,v 1.1 2004/03/08 07:30:40 ngoto Exp $

require 'matrix'
require 'bio/db/pdb'

module Bio; class PDB

  module Utils
    #The methods in this mixin should be applicalbe to all PDB objects
    
    #Returns the coordinates of the geometric centre (average co-ord)
    #of any AtomFinder (or .atoms) implementing object
    def geometricCentre()
      
      x = y = z = count = 0
      
      self.each_atom{ |atom|
	x += atom.x
	y += atom.y
	z += atom.z
	count += 1
      }
      
      x = x / count
      y = y / count
      z = z / count
      
      Coordinate[x,y,z]
      
    end

    #Returns the coords of the centre of gravity for any
    #AtomFinder implementing object
    #Blleurgh! - working out what element it is from the atom name is
    #tricky - this'll work in most cases but not metals etc...
    #a proper element field is included in some PDB files but not all.
    ElementMass = {
      'H' => 1,
      'C' => 12,
      'N' => 14,
      'O' => 16,
      'S' => 32,
      'P' => 31
    }

    def centreOfGravity()
      
      x = y = z = total = 0
      
      self.each_atom{ |atom|
	element = atom.element[0,1]
	mass    = ElementMass[element]
	total += mass
	x += atom.x * mass
	y += atom.y * mass
	z += atom.z * mass
      }
      
      x = x / total
      y = y / total
      z = z / total
      
      Coordinate[x,y,z]
      
    end

    #Perhaps distance and dihedral would be better off as class methods?
    #(rather) than instance methods
    def self.distance(coord1,coord2)
      coord1 = to_xyz(coord1)
      coord2 = to_xyz(coord2)
      (coord1 - coord2).r
    end

    def self.dihedral_angle(coord1,coord2,coord3,coord4)
        
      (a1,b1,c1,d) = calculatePlane(coord1,coord2,coord3)
      (a2,b2,c2)   = calculatePlane(coord2,coord3,coord4)
      
      torsion = acos((a1*a2 + b1*b2 + c1*c2)/(Math.sqrt(a1**2 + b1**2 + c1**2) * Math.sqrt(a2**2 + b2**2 + c2**2)))
      
      if ((a1*coord4.x + b1*coord4.y + c1*coord4.z + d) < 0)
        -torsion
      else
        torsion
      end
    end
      
    #Implicit conversion into Vector or Bio::PDB::Coordinate
    def self.to_xyz(obj)
      unless obj.is_a?(Vector)
        begin
          obj = obj.xyz
        rescue NameError
          obj = Vector.elements(obj.to_a)
        end
      end
      obj
    end

    #Methods required for the dihedral angle calculations
    #perhaps these should go in some separate Math module
    def self.rad2deg(r)
      (r/Math::PI)*180
    end
    
    def self.acos(x)
      Math.atan2(Math.sqrt(1 - x**2),x)
    end
      
    def self.calculatePlane(coord1,coord2,coord3)
      a = coord1.y * (coord2.z - coord3.z) +
          coord2.y * (coord3.z - coord1.z) + 
          coord3.y * (coord1.z - coord2.z)
      b = coord1.z * (coord2.x - coord3.x) +
          coord2.z * (coord3.x - coord1.x) + 
          coord3.z * (coord1.x - coord2.x)
      c = coord1.x * (coord2.y - coord3.y) +
          coord2.x * (coord3.y - coord1.y) + 
          coord3.x * (coord1.y - coord2.y)
      d = -1 *
          (
           (coord1.x * (coord2.y * coord3.z - coord3.y * coord2.z)) +
           (coord2.x * (coord3.y * coord1.z - coord1.y * coord3.z)) +
           (coord3.x * (coord1.y * coord2.z - coord2.y * coord1.z))
           )

      return [a,b,c,d]
        
    end

    #Every class in the heirarchy implements finder, this takes 
    #a class which determines which type of object to find, the associated
    #block is then run in classic .find style
    def finder(findtype,&block)
      if findtype == Bio::PDB::Atom
        return self.find_atom(&block)
      elsif findtype == Bio::PDB::Residue
        return self.find_residue(&block)
      elsif findtype == Bio::PDB::Chain
        return self.find_chain(&block)
      elsif findtype == Bio::PDB::Model
        return self.find_model(&block)
      else
        raise TypeError, "You can't find a #{findtype}"
      end
    end
  end #module Utils
  
  #The *Finder modules implement a find_* method which returns
  #an array of anything for which the block evals true
  #(suppose Enumerable#find_all method).
  #The each_* style methods act as classic iterators.
  module ModelFinder
    def find_model()
      array = []
      self.each_model{ |model|
        array.push(model) if yield(model)
      }
      return array
    end
  end
  
  #The heirarchical nature of the objects allow us to re-use the
  #methods from the previous level - e.g. A PDB object can use the .models
  #method defined in ModuleFinder to iterate through the models to find the
  #chains
  module ChainFinder
    def find_chain()
      array = []
      self.each_chain{ |chain|
        array.push(chain) if yield(chain)
      }
      return array
    end
    def each_chain()
      self.each_model{ |model|
	model.each{ |chain| yield chain }
      }
    end
  end
  
  module ResidueFinder
    def find_residue()
      array = []
      self.each_residue{ |residue|
        array.push(residue) if yield(residue)
      }
      return array
    end
    def each_residue()
      self.each_chain{ |chain|
	chain.each{ |residue| yield residue }
      }
    end
  end
  
  module AtomFinder
    def find_atom()
      array = []
      self.each_atom{ |atom|
        array.push(atom) if yield(atom)
      }
      return array
    end
    def each_atom()
      self.each_residue{ |residue|
	residue.each{ |atom| yield atom }
      }
    end
  end

end; end #module Bio; class PDB

