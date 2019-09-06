#!/usr/bin/env cwl-runner

cwlVersion: v1.0
class: CommandLineTool
baseCommand: [ruby]

inputs:
 - id: script
   type: File
   default:
     class: File
     location: fastq2html.rb
   inputBinding:
     position: -1
 - id: fastq
   type: File[]
   inputBinding:
     position: 1

outputs:
 - id: out
   type: stdout
stdout: $(inputs.script.nameroot)-$(inputs.fastq[0].nameroot).html
