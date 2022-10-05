#merged kmers and create unique header per contig
require 'fileutils'

def mergeCDHIT(input)
    assemblyList=Dir.glob(input)
    tempDataName="#{File.basename(assemblyList[0])}_temp"
    tempData=File.open("#{tempDataName}","w+")
    assemblyList.each {|x| tempData.puts(File.read(x))}
    get_lengths("#{tempDataName}")
    FileUtils.rm_rf("#{Dir.pwd}/#{tempDataName}")
end

def get_lengths(input)
    inputData=File.read(input).split(">").drop(1)
    headers=[]
    sequences=[]
    inputData.each do |indv|
      nl=indv.index("\n")
      header=indv[0..nl-1]
      header=header.gsub("\s","_")
      seq=indv[nl+1..-1]
      seq.gsub!(/\n/,'')
      headers.push(header)
      sequences.push(seq)
    end
    
    headers=headers.group_by(&:itself).flat_map do |k,v| 
        v.size.times.map {|n| n.zero? ? k : "#{k}_#{n}"}
    end
    out_name=input.split("_")[1]
    output=File.open("#{out_name}_merged.fasta","w+")

    headers.each_with_index do |x,i|
        output.puts(x)
        output.puts(sequences[i])
    end
  end
folders=Dir.glob("./references/denovo/*")
folders.each do |x|
    mergeCDHIT("#{x}/asmbly*")
end
