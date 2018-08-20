#!/usr/bin/env nextflow

threads = params.threads

// Trimmomatic options
leading = params.leading
trailing = params.trailing
slidingwindow = params.slidingwindow
minlen = params.minlen
adapters = params.adapters

if( params.help ) {
    return help()
}

Channel
    .fromFilePairs( params.reads, flat: true )
    .into { read_pairs; fastqc_pairs }

process QualityControl {
    tag { dataset_id }
    
    publishDir "${params.output}/QualityControlOutput", mode: "symlink",
        saveAs: { filename ->
            if(filename.indexOf("P.fastq") > 0) "Paired/$filename"
            else if(filename.indexOf(".log") > 0) "Log/$filename"
            else {}
        }
    
    input:
        set dataset_id, file(forward), file(reverse) from read_pairs
    
    output:
        set dataset_id, file("${dataset_id}.1P.fastq.gz"), file("${dataset_id}.2P.fastq.gz") into (paired_fastq)
        set dataset_id, file("${dataset_id}.trimmomatic.stats.log") into (trimmomatic_logs)
    
    """
    /usr/lib/jvm/java-7-openjdk-amd64/bin/java -jar ${TRIMMOMATIC}/trimmomatic-0.36.jar \
        PE \
        -threads ${threads} \
        $forward $reverse -baseout ${dataset_id} \
        ILLUMINACLIP:${adapters}:2:30:10:3:TRUE \
        LEADING:${leading} \
        TRAILING:${trailing} \
        SLIDINGWINDOW:${slidingwindow} \
        MINLEN:${minlen} \
        2> ${dataset_id}.trimmomatic.stats.log
    
    gzip -c ${dataset_id}_1P > ${dataset_id}.1P.fastq.gz
    gzip -c ${dataset_id}_2P > ${dataset_id}.2P.fastq.gz
    rm ${dataset_id}_1P
    rm ${dataset_id}_2P
    rm ${dataset_id}_1U
    rm ${dataset_id}_2U
    """
}

process AssembleReads {
    tag { dataset_id }
    
    publishDir "${params.output}/AssembledFiles", mode: "symlink"
    
    input:
        set dataset_id, file(forward), file(reverse) from paired_fastq
    
    output:
        set dataset_id, file("${dataset_id}.contigs.fa") into (idba_assemblies)
    
    script:
    """
    mkdir -p temp/idba
	fq2fa --merge --filter <( zcat $forward) <( zcat $reverse ) temp/interleavened.fasta
    idba_ud --num_threads 60 -l temp/interleavened.fasta -o temp/idba

	cp temp/idba/contig.fa ${dataset_id}.contigs.fasta

    """
}

def nextflow_version_error() {
    println ""
    println "This workflow requires Nextflow version 0.25 or greater -- You are running version $nextflow.version"
    println "Run ./nextflow self-update to update Nextflow to the latest available version."
    println ""
    return 1
}

def help() {
    println ""
    println "Program: summit-assembly"
    println "Version: $workflow.repository - $workflow.revision [$workflow.commitId]"
    println "Contact: Steven Lakin <steven.m.lakin@gmail.com>"
    println ""
    println "Usage:    nextflow summit-assembly.nf [options]"
    println ""
    println "Input/output options:"
    println ""
    println "    --reads         STR      path to FASTQ formatted input sequences"
    println "    --output        STR      directory to write process outputs to"
    println ""
    println "Trimming options:"
    println ""
    println "    --leading       INT      cut bases off the start of a read, if below a threshold quality"
    println "    --minlen        INT      drop the read if it is below a specified length"
    println "    --slidingwindow INT      perform sw trimming, cutting once the average quality within the window falls below a threshold"
    println "    --trailing      INT      cut bases off the end of a read, if below a threshold quality"
    println ""
    println "Algorithm options:"
    println ""
    println "    --threads       INT      number of threads to use for each process"
    println ""
    println "Help options:"
    println ""
    println "    --help                   display this message"
    println ""
    return 1
}





















