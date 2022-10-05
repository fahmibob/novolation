nextflow.enable.dsl=2

params.job=false
params.thread=4
params.forking=10
params.cdhitIn=false
params.filterByFile=false

params.identity=0.90
params.coverage=0.90

params.sizeLimit=50

workflow {
  if (params.cdhitIn){
    Channel.fromPath(params.cdhitIn)
      .map { file -> tuple(file.simpleName, file)}
      .set{cdhit_ch}
  }

  if (params.filterByFile){
    def filterList = new File(params.filterByFile).collect {it}
    cdhit_ch = cdhit_ch.map { if (it[0].toString() in filterList) {it} }
  }

  cdhitProcess(cdhit_ch)
}

process cdhitProcess {
  publishDir "$baseDir/output/$params.job", mode: 'copy'
  errorStrategy 'ignore'
  maxForks params.forking

  input:
  tuple val(sampleName), path(inputFile)

  output:
  path("*cdhit.fasta")

  script:
  """
  cd-hit-est -i $inputFile -c $params.identity -M 0\
  -aS $params.coverage -o $sampleName'_cdhit.fasta'
  """
}

process coverage {
  label "coverage"

  input:
  tuple val(sampleName), path(forward), path(reverse)

  output:
  path("coverage.txt")
  script:
  """
  bwa index $params.input
  bwa mem -t 8 $params.input $forward $reverse | samtools sort -@8 -o $sampleName'.bam' -
  samtools depth -a $sampleName'.bam' | awk '{c++;s+=\$3}END{print s/c}' > coverage.txt
  """
}
