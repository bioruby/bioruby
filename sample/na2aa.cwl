#!/usr/bin/env cwl-runner

cwlVersion: v1.0
class: CommandLineTool
baseCommand: [ruby]

inputs:
 - id: script
   type: File
   default:
     class: File
     location: na2aa.rb
   inputBinding:
     position: -1
 - id: seqFile
   type: File[]
   inputBinding:
     position: 1

outputs:
 - id: out
   type: stdout
stdout: $(inputs.script.nameroot)-$(inputs.seqFile[0].nameroot).fst
