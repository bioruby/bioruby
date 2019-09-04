#!/usr/bin/env cwl-runner

cwlVersion: v1.0
class: CommandLineTool
baseCommand: [ruby]
arguments: [$(inputs.script), $(inputs.seqFile)]

inputs:
 - id: script
   type: File
   default:
     class: File
     location: na2aa.rb
 - id: seqFile
   type: File[]

outputs:
 - id: out
   type: stdout
stdout: $(inputs.script.nameroot)-$(inputs.seqFile[0].nameroot).fst
