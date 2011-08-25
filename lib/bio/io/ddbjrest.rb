#
# = bio/io/ddbjrest.rb - DDBJ Web API for Biology (WABI) access class via REST
#
# Copyright::	Copyright (C) 2011
#		Naohisa Goto <ng@bioruby.org>
# License::	The Ruby License
#
# == Description
# 
# This file contains Bio::DDBJ::REST, DDBJ Web API for Biology (WABI) access
# classes via REST (Representational State Transfer) protocol.
#
# == References
#
# * http://xml.nig.ac.jp/
#

require 'bio/command'
require 'bio/db/genbank/ddbj'

module Bio
class DDBJ

  # == Description
  #
  # The module Bio::DDBJ::REST is the namespace for the DDBJ Web API for
  # Biology (WABI) via REST protocol. Under the Bio::DDBJ::REST,
  # following classes are available.
  #
  # * Bio::DDBJ::REST::DDBJ
  # * Bio::DDBJ::REST::Blast
  # * Bio::DDBJ::REST::ClustalW
  # * Bio::DDBJ::REST::Mafft
  # * Bio::DDBJ::REST::RequestManager
  #
  # Following classes are NOT available, but will be written in the future.
  #
  # * Bio::DDBJ::REST::GetEntry
  # * Bio::DDBJ::REST::ARSA
  # * Bio::DDBJ::REST::VecScreen
  # * Bio::DDBJ::REST::PhylogeneticTree
  # * Bio::DDBJ::REST::Gib
  # * Bio::DDBJ::REST::Gtop
  # * Bio::DDBJ::REST::GTPS
  # * Bio::DDBJ::REST::GIBV
  # * Bio::DDBJ::REST::GIBIS
  # * Bio::DDBJ::REST::SPS
  # * Bio::DDBJ::REST::TxSearch
  # * Bio::DDBJ::REST::Ensembl
  # * Bio::DDBJ::REST::NCBIGenomeAnnotation
  #
  # Read the document of each class for details.
  #
  # In addition, there is a private class Bio::DDBJ::REST::WABItemplate,
  # basic class for the above classes. Normal users should not use the
  # WABItemplate class directly.
  #
  module REST

    # Bio::DDBJ::REST::WABItemplate is a private class to provide common
    # methods to access DDBJ Web API for Biology (WABI) services by using
    # REST protocol.
    #
    # Normal users should not use the class directly.
    #
    class WABItemplate

      # hostname for the WABI service
      WABI_HOST = 'xml.nig.ac.jp'

      # path for the WABI service
      WABI_PATH = '/rest/Invoke'

      private

      # Creates a new object.
      def initialize
        @http = Bio::Command.new_http(WABI_HOST)
        @service = self.class.to_s.split(/\:\:/)[-1]
      end

      # (private) query to the service by using POST method
      def _wabi_post(method_name, param)
        parameters = {
          'service' => @service,
          'method' => method_name
        }
        parameters.update(param)
        #$stderr.puts parameters.inspect
        r = Bio::Command.http_post_form(@http, WABI_PATH, parameters)
        #$stderr.puts r.inspect
        #$stderr.puts "-"*78
        #$stderr.puts r.body
        #$stderr.puts "-"*78
        r.body
      end

      def self.define_wabi_method(array,
                                  ruby_method_name = nil,
                                  public_method_name = nil)
        wabi_method_name = array[0]
        ruby_method_name ||= wabi_method_name
        public_method_name ||= wabi_method_name
        arg = array[1..-1]
        arguments = arg.join(', ')
        parameters = "{" +
          arg.collect { |x| "#{x.dump} => #{x}" }.join(", ") + "}"
        module_eval "def #{ruby_method_name}(#{arguments})
                       param = #{parameters}
                       _wabi_post(#{wabi_method_name.dump}, param)
                     end
                     def self.#{public_method_name}(#{arguments})
                       self.new.#{public_method_name}(#{arguments})
                     end"
        self
      end
      private_class_method :define_wabi_method

      def self.def_wabi(array)
        define_wabi_method(array)
      end
      private_class_method :def_wabi

      def self.def_wabi_custom(array)
        ruby_method_name = '_' + array[0]
        define_wabi_method(array, ruby_method_name)
        module_eval "private :#{ruby_method_name}"
        self
      end
      private_class_method :def_wabi_custom

      def self.def_wabi_async(array)
        m = array[0]
        def_wabi_custom(array)
        module_eval "def #{m}(*arg)
            ret = _#{m}(*arg)
            if /Your +requestId +is\s*\:\s*(.+)\s*/i =~ ret.to_s then
              return $1
            else
              raise \"unknown return value: \#\{ret.inspect\}\"
            end
          end"
        self
      end
      private_class_method :def_wabi_async
    end #class WABItemplate

    # === Description
    #
    # DDBJ (DNA DataBank of Japan) entry retrieval functions.
    #
    # * http://xml.nig.ac.jp/wabi/Method?serviceName=DDBJ&mode=methodList&lang=en
    #
    # === Examples
    #
    # see http://xml.nig.ac.jp/wabi/Method?serviceName=DDBJ&mode=methodList&lang=en
    #
    class DDBJ < WABItemplate

      # Number and ratio of each base such as A,T,G,C.
      #
      # see http://xml.nig.ac.jp/wabi/Method?&lang=en&serviceName=DDBJ&methodName=countBasePair&mode=methodDetail
      # ---
      # *Arguments*:
      # * (required) _accession_: (String) accession
      # *Returns*:: (String) tab-deliminated text
      def countBasePair(accession); end if false #dummy
      def_wabi %w( countBasePair accession )

      # see http://xml.nig.ac.jp/wabi/Method?&lang=en&serviceName=DDBJ&methodName=get&mode=methodDetail
      def get(accessionList, paramList); end if false #dummy
      def_wabi %w( get accessionList paramList )

      # see http://xml.nig.ac.jp/wabi/Method?&lang=en&serviceName=DDBJ&methodName=getAllFeatures&mode=methodDetail
      def getAllFeatures(accession); end if false #dummy
      def_wabi %w( getAllFeatures accession )

      # see http://xml.nig.ac.jp/wabi/Method?&lang=en&serviceName=DDBJ&methodName=getFFEntry&mode=methodDetail
      def getFFEntry(accession); end if false #dummy
      def_wabi %w( getFFEntry accession )

      # http://xml.nig.ac.jp/wabi/Method?&lang=en&serviceName=DDBJ&methodName=getRelatedFeatures&mode=methodDetail
      def getRelatedFeatures(accession, start, stop); end if false #dummy
      def_wabi %w( getRelatedFeatures accession start stop )

      # see http://xml.nig.ac.jp/wabi/Method?&lang=en&serviceName=DDBJ&methodName=getRelatedFeaturesSeq&mode=methodDetail
      def getRelatedFeaturesSeq(accession, start, stop); end if false #dummy
      def_wabi %w( getRelatedFeaturesSeq accession start stop )
    end #class DDBJ

    # === Description
    #
    # DDBJ (DNA DataBank of Japan) BLAST web service.
    # See below for details and examples.
    #
    # Users normally would want to use searchParamAsync or
    # searchParallelAsync with RequestManager.
    #
    # * http://xml.nig.ac.jp/wabi/Method?serviceName=Blast&mode=methodList&lang=en
    class Blast < WABItemplate

      # see http://xml.nig.ac.jp/wabi/Method?&lang=en&serviceName=Blast&methodName=extractPosition&mode=methodDetail
      def extractPosition(result); end if false #dummy
      def_wabi %w( extractPosition result )

      # see http://xml.nig.ac.jp/wabi/Method?&lang=en&serviceName=Blast&methodName=getSupportDatabaseList&mode=methodDetail
      def getSupportDatabaseList(); end if false #dummy
      def_wabi %w( getSupportDatabaseList )

      # see http://xml.nig.ac.jp/wabi/Method?&lang=en&serviceName=Blast&methodName=searchParallel&mode=methodDetail
      def searchParallel(program, database, query, param); end if false #dummy
      def_wabi %w( searchParallel program database query param )

      # see http://xml.nig.ac.jp/wabi/Method?&lang=en&serviceName=Blast&methodName=searchParallelAsync&mode=methodDetail
      def searchParallelAsync(program, database,
                              query, param); end if false #dummy
      def_wabi_async %w( searchParallelAsync program database query param )

      # see http://xml.nig.ac.jp/wabi/Method?&lang=en&serviceName=Blast&methodName=searchParam&mode=methodDetail
      def searchParam(program, database, query, param); end if false #dummy
      def_wabi %w( searchParam program database query param )

      # see http://xml.nig.ac.jp/wabi/Method?&lang=en&serviceName=Blast&methodName=searchParamAsync&mode=methodDetail
      def searchParamAsync(program, database,
                           query, param); end if false #dummy
      def_wabi_async %w( searchParamAsync program database query param )

      # see http://xml.nig.ac.jp/wabi/Method?&lang=en&serviceName=Blast&methodName=searchSimple&mode=methodDetail
      def searchSimple(program, database, query); end if false #dummy
      def_wabi %w( searchSimple program database query )

      # see http://xml.nig.ac.jp/wabi/Method?&lang=en&serviceName=Blast&methodName=searchSimpleAsync&mode=methodDetail
      def searchSimpleAsync(program, database, query); end if false #dummy
      def_wabi_async %w( searchSimpleAsync program database query )

    end #class Blast

    # === Description
    #
    # DDBJ (DNA DataBank of Japan) web service of ClustalW multiple sequence
    # alignment software.
    # See below for details and examples.
    #
    # * http://xml.nig.ac.jp/wabi/Method?serviceName=ClustalW&mode=methodList&lang=en
    class ClustalW < WABItemplate
      # see http://xml.nig.ac.jp/wabi/Method?&lang=en&serviceName=ClustalW&methodName=analyzeParam&mode=methodDetail
      def analyzeParam(query, param); end if false #dummy
      def_wabi %w( analyzeParam query param )

      # see http://xml.nig.ac.jp/wabi/Method?&lang=en&serviceName=ClustalW&methodName=analyzeParamAsync&mode=methodDetail
      def analyzeParamAsync(query, param); end if false #dummy
      def_wabi_async %w( analyzeParamAsync query param )

      # http://xml.nig.ac.jp/wabi/Method?&lang=en&serviceName=ClustalW&methodName=analyzeSimple&mode=methodDetail
      def analyzeSimple(query); end if false #dummy
      def_wabi %w( analyzeSimple query )

      # http://xml.nig.ac.jp/wabi/Method?&lang=en&serviceName=ClustalW&methodName=analyzeSimpleAsync&mode=methodDetail
      def analyzeSimpleAsync(query); end if false #dummy
      def_wabi_async %w( analyzeSimpleAsync query )
    end #lcass ClustalW

    # === Description
    #
    # DDBJ (DNA DataBank of Japan) web service of MAFFT multiple sequence
    # alignment software.
    # See below for details and examples.
    #
    # * http://xml.nig.ac.jp/wabi/Method?serviceName=Mafft&mode=methodList&lang=en
    class Mafft < WABItemplate
      # see http://xml.nig.ac.jp/wabi/Method?&lang=en&serviceName=Mafft&methodName=analyzeParam&mode=methodDetail
      def analyzeParam(query, param); end if false #dummy
      def_wabi %w( analyzeParam query param )

      # see http://xml.nig.ac.jp/wabi/Method?&lang=en&serviceName=Mafft&methodName=analyzeParamAsync&mode=methodDetail
      def analyzeParamAsync(query, param); end if false #dummy
      def_wabi_async %w( analyzeParamAsync query param )

      # see http://xml.nig.ac.jp/wabi/Method?&lang=en&serviceName=Mafft&methodName=analyzeSimple&mode=methodDetail
      def analyzeSimple(query); end if false #dummy
      def_wabi %w( analyzeSimple query )

      # see http://xml.nig.ac.jp/wabi/Method?&lang=en&serviceName=Mafft&methodName=analyzeSimpleAsync&mode=methodDetail
      def analyzeSimpleAsync(query); end if false #dummy
      def_wabi_async %w( analyzeSimpleAsync query )
    end #lcass Mafft


    # === Description
    #
    # DDBJ (DNA DataBank of Japan) special web service to get result of
    # asynchronous web service.
    # See below for details and examples.
    #
    # * http://xml.nig.ac.jp/wabi/Method?serviceName=RequestManager&mode=methodList&lang=en
    class RequestManager < WABItemplate

      # see http://xml.nig.ac.jp/wabi/Method?&lang=en&serviceName=RequestManager&methodName=getAsyncResult&mode=methodDetail
      def getAsyncResult(requestId); end if false #dummy
      def_wabi %w( getAsyncResult requestId )

      # Waits until the query is finished and the result is returnd,
      # with calling getAsyncResult.
      # 
      # This is BioRuby original method.
      # ---
      # *Arguments*:
      # * (required) _requestID_: (String) requestId
      # *Returns*:: (String) result
      def wait_getAsyncResult(requestId)
        sleeptime = 2
        while true
          result = getAsyncResult(requestId)
          case result.to_s
          when /The search and analysis service by WWW is very busy now/
            raise result.to_s.strip + '(Alternatively, wrong options may be given.)'
          when /\AYour job has not (?:been )?completed yet/
            sleeptime = 2 + rand(4)
          when /\AERROR:/
            raise result.to_s.strip
          else
            return result
          end #case
          if $VERBOSE then
            $stderr.puts "DDBJ REST: requestId: #{requestId} -- waitng #{sleeptime} sec."
          end
          sleep(sleeptime)
        end
        # will never be reached here
        raise "Bug?"
      end

      # the same as Bio::DDBJ::REST::RequestManager#wait_getAsyncResult
      def self.wait_getAsyncResult(requestId)
        self.new.wait_getAsyncResult(requestId)
      end

    end #class RequestManager

  end #module REST
end #class DDBJ
end #module Bio


