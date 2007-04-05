#
# = bio/db/pdb/utils.rb - Utility modules for PDB
#
# Copyright::  Copyright (C) 2004, 2006
#              Alex Gutteridge <alexg@ebi.ac.uk>
#              Naohisa Goto <ng@bioruby.org>
# License::    The Ruby License
#
# $Id: utils.rb,v 1.7 2007/04/05 23:35:41 trevor Exp $
#
# = Bio::PDB::Utils
#
# Bio::PDB::Utils
#
# = Bio::PDB::ModelFinder
#
# Bio::PDB::ModelFinder
#
# = Bio::PDB::ChainFinder
#
# Bio::PDB::ChainFinder
#
# = Bio::PDB::ResidueFinder
#
# Bio::PDB::ResidueFinder
#
# = Bio::PDB::AtomFinder
#
# Bio::PDB::AtomFinder
#
# = Bio::PDB::HeterogenFinder
#
# Bio::PDB::HeterogenFinder
#
# = Bio::PDB::HetatmFinder
#
# Bio::PDB::HetatmFinder
#

require 'matrix'
require 'bio/db/pdb'

module Bio; class PDB

  # Utility methods for PDB data.
  # The methods in this mixin should be applicalbe to all PDB objects.
  #
  # Bio::PDB::Utils is included by Bio::PDB, Bio::PDB::Model,
  # Bio::PDB::Chain, Bio::PDB::Residue, and Bio::PDB::Heterogen classes.
  module Utils
    
    # Returns the coordinates of the geometric centre (average co-ord)
    # of any AtomFinder (or .atoms) implementing object
    #
    # If you want to get the geometric centre of hetatms,
    # call geometricCentre(:each_hetatm).
    def geometricCentre(method = :each_atom)
      x = y = z = count = 0
      
      self.__send__(method) do |atom|
        x += atom.x
        y += atom.y
        z += atom.z
        count += 1
      end
      
      x = (x / count)
      y = (y / count)
      z = (z / count)
     
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

    # calculates centre of gravitiy
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

    #--
    #Perhaps distance and dihedral would be better off as class methods?
    #(rather) than instance methods
    #++

    # Calculates distance between _coord1_ and _coord2_.
    def distance(coord1, coord2)
      coord1 = convert_to_xyz(coord1)
      coord2 = convert_to_xyz(coord2)
      (coord1 - coord2).r
    end
    module_function :distance

    # Calculates dihedral angle.
    def dihedral_angle(coord1, coord2, coord3, coord4)
      (a1,b1,c1,d) = calculatePlane(coord1,coord2,coord3)
      (a2,b2,c2)   = calculatePlane(coord2,coord3,coord4)
      
      torsion = acos((a1*a2 + b1*b2 + c1*c2)/(Math.sqrt(a1**2 + b1**2 + c1**2) * Math.sqrt(a2**2 + b2**2 + c2**2)))
      
      if ((a1*coord4.x + b1*coord4.y + c1*coord4.z + d) < 0)
        -torsion
      else
        torsion
      end
    end
    module_function :dihedral_angle
      
    # Implicit conversion into Vector or Bio::PDB::Coordinate
    def convert_to_xyz(obj)
      unless obj.is_a?(Vector)
        begin
          obj = obj.xyz
        rescue NameError
          obj = Vector.elements(obj.to_a)
        end
      end
      obj
    end
    module_function :convert_to_xyz

    # (Deprecated) alias of convert_to_xyz(obj)
    def self.to_xyz(obj)
      convert_to_xyz(obj)
    end

    #--
    #Methods required for the dihedral angle calculations
    #perhaps these should go in some separate Math module
    #++

    # radian to degree
    def rad2deg(r)
      (r/Math::PI)*180
    end
    module_function :rad2deg

    # acos
    def acos(x)
      Math.atan2(Math.sqrt(1 - x**2),x)
    end
    module_function :acos

    # calculates plane
    def calculatePlane(coord1, coord2, coord3)
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
    module_function :calculatePlane

    # Every class in the heirarchy implements finder, this takes 
    # a class which determines which type of object to find, the associated
    # block is then run in classic .find style.
    # 
    # The method might be deprecated.
    # You'd better using find_XXX  directly.
    def finder(findtype, &block) #:yields: obj
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

  #--
  #The *Finder modules implement a find_* method which returns
  #an array of anything for which the block evals true
  #(suppose Enumerable#find_all method).
  #The each_* style methods act as classic iterators.
  #++

  # methods to access models
  #
  # XXX#each_model must be defined.
  #
  # Bio::PDB::ModelFinder is included by Bio::PDB::PDB.
  #
  module ModelFinder
    # returns an array containing all chains for which given block
    # is not +false+ (similar to Enumerable#find_all).
    def find_model
      array = []
      self.each_model do |model|
        array.push(model) if yield(model)
      end
      return array
    end
  end #module ModelFinder
  
  #--
  #The heirarchical nature of the objects allow us to re-use the
  #methods from the previous level - e.g. A PDB object can use the .models
  #method defined in ModuleFinder to iterate through the models to find the
  #chains
  #++

  # methods to access chains
  #
  # XXX#each_model must be defined.
  #
  # Bio::PDB::ChainFinder is included by Bio::PDB::PDB and Bio::PDB::Model.
  #
  module ChainFinder

    # returns an array containing all chains for which given block
    # is not +false+ (similar to Enumerable#find_all).
    def find_chain
      array = []
      self.each_chain do |chain|
        array.push(chain) if yield(chain)
      end
      return array
    end

    # iterates over each chain
    def each_chain(&x) #:yields: chain
      self.each_model { |model| model.each(&x) }
    end

    # returns all chains
    def chains
      array = []
      self.each_model { |model| array.concat(model.chains) }
      return array
    end
  end #module ChainFinder
  
  # methods to access residues
  #
  # XXX#each_chain must be defined.
  #
  # Bio::PDB::ResidueFinder is included by Bio::PDB::PDB, Bio::PDB::Model,
  # and Bio::PDB::Chain.
  #
  module ResidueFinder

    # returns an array containing all residues for which given block
    # is not +false+ (similar to Enumerable#find_all).
    def find_residue
      array = []
      self.each_residue do |residue|
        array.push(residue) if yield(residue)
      end
      return array
    end

    # iterates over each residue
    def each_residue(&x) #:yields: residue
      self.each_chain { |chain| chain.each(&x) }
    end

    # returns all residues
    def residues
      array = []
      self.each_chain { |chain| array.concat(chain.residues) }
      return array
    end
  end #module ResidueFinder
  
  # methods to access atoms
  #
  # XXX#each_residue must be defined.
  module AtomFinder
    # returns an array containing all atoms for which given block
    # is not +false+ (similar to Enumerable#find_all).
    def find_atom
      array = []
      self.each_atom do |atom|
        array.push(atom) if yield(atom)
      end
      return array
    end

    # iterates over each atom
    def each_atom(&x) #:yields: atom
      self.each_residue { |residue| residue.each(&x) }
    end

    # returns all atoms
    def atoms
      array = []
      self.each_residue { |residue| array.concat(residue.atoms) }
      return array
    end
  end #module AtomFinder

  # methods to access HETATMs
  #
  # XXX#each_heterogen must be defined.
  #
  # Bio::PDB::HetatmFinder is included by Bio::PDB::PDB, Bio::PDB::Model,
  # Bio::PDB::Chain, and Bio::PDB::Heterogen.
  #
  module HetatmFinder
    # returns an array containing all HETATMs for which given block
    # is not +false+ (similar to Enumerable#find_all).
    def find_hetatm
      array = []
      self.each_hetatm do |hetatm|
        array.push(hetatm) if yield(hetatm)
      end
      return array
    end

    # iterates over each HETATM
    def each_hetatm(&x) #:yields: hetatm
      self.each_heterogen { |heterogen| heterogen.each(&x) }
    end

    # returns all HETATMs
    def hetatms
      array = []
      self.each_heterogen { |heterogen| array.concat(heterogen.hetatms) }
      return array
    end
  end #module HetatmFinder

  # methods to access heterogens (compounds or ligands)
  #
  # XXX#each_chain must be defined.
  #
  # Bio::PDB::HeterogenFinder is included by Bio::PDB::PDB, Bio::PDB::Model,
  # and Bio::PDB::Chain.
  #
  module HeterogenFinder
    # returns an array containing all heterogens for which given block
    # is not +false+ (similar to Enumerable#find_all).
    def find_heterogen
      array = []
      self.each_heterogen do |heterogen|
        array.push(heterogen) if yield(heterogen)
      end
      return array
    end

    # iterates over each heterogens
    def each_heterogen(&x) #:yields: heterogen
      self.each_chain { |chain| chain.each_heterogen(&x) }
    end

    # returns all heterogens
    def heterogens
      array = []
      self.each_chain { |chain| array.concat(chain.heterogens) }
      return array
    end
  end #module HeterogenFinder

end; end #module Bio; class PDB

