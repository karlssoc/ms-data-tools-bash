#!/bin/bash

set -xe

# Specify paths of tools and files. Change them accordingly.
dataDirPath="/mnt/DATA_DISKS/WORKSPACE2/karlssoc/tmp/tppdata/200119_reviewed"
fastaPath="/mnt/DATA_DISKS/WORKSPACE2/karlssoc/projects/akim/fastadb/20200119/reviewed/2020-01-19-td-uniprot-proteome%3AUP000000589+reviewed%3Ayes_PROCAL_RT_CONT.fasta"
msfraggerPath="/mnt/DATA_DISKS/WORKSPACE2/karlssoc/bin/MSFragger/MSFragger-2.1.jar"
fraggerParamsPath="/mnt/DATA_DISKS/WORKSPACE2/karlssoc/tmp/tppdata/200119_reviewed/closed_fragger.params"
philosopherPath="/mnt/DATA_DISKS/WORKSPACE2/karlssoc/bin/philosopher/philosopher_v2.0.0/philosopher"
#crystalcPath="Crystal-C.jar"
#crystalcParameterPath="crystalc.pepXML.params"
decoyPrefix="DECOY"


# cp /mnt/harry/temp/mzml/*.mzML .

# Run MSFragger. Change the number behind -Xmx according to your computer's memory size.
java -Xmx128G -jar $msfraggerPath $fraggerParamsPath $dataDirPath/*.mzML

# Move pepXML files to current directory.
#mv $dataDirPath/*.pepXML ./

# Move tsv files to current directory.
#mv $dataDirPath/*.tsv ./ # Comment this line if localize_delta_mass = 0 in your fragger.params file.

# Run Crystal-C If it is an open search, run Crystal-C. Otherwise, don't run it by commenting the following for-loop
#for myFile in ./*.pepXML
#do
#	java -Xmx64G -cp $crystalcPath Main $crystalcParameterPath $myFile
#done

# Run PeptideProphet, ProteinProphet, and FDR filtering inside Philosopher
$philosopherPath workspace --clean
$philosopherPath workspace --init
$philosopherPath database --annotate $fastaPath --prefix $decoyPrefix

# Pick one from the following three commands and comment rest of two.
$philosopherPath peptideprophet --nonparam --expectscore --decoyprobs --ppm --accmass --decoy $decoyPrefix --database $fastaPath ./*.pepXML # For closed search
#$philosopherPath peptideprophet --nonparam --expectscore --decoyprobs --masswidth 1000.0 --clevel -2 --decoy $decoyPrefix --combine --database $fastaPath ./*.pepXML # For open search
#$philosopherPath peptideprophet --nonparam --expectscore --decoyprobs --ppm --accmass --nontt --decoy $decoyPrefix --database $fastaPath ./*.pepXML # For non-specific closed search

$philosopherPath proteinprophet --maxppmdiff 2000000 ./*.pep.xml

# Pick one from the following two commands and comment the other one.
$philosopherPath filter --sequential --razor --mapmods --tag $decoyPrefix --pepxml ./ --protxml ./interact.prot.xml # closed or non-specific closed search
#$philosopherPath filter --sequential --razor --mapmods --tag $decoyPrefix --pepxml ./interact.pep.xml --protxml ./interact.prot.xml # open search

$philosopherPath report
#$philosopherPath workspace --clean
