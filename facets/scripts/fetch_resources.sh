mkdir -p $(dirname $0)/../resources
wget -O $(dirname $0)/../resources/dbsnp_151.common.hg38.vcf.gz https://ftp.ncbi.nih.gov/snp/organisms/human_9606/VCF/00-common_all.vcf.gz
wget -O $(dirname $0)/../resources/dbsnp_151.common.hg38.vcf.gz.tbi https://ftp.ncbi.nih.gov/snp/organisms/human_9606/VCF/00-common_all.vcf.gz.tbi


echo -e "Checking file integrity.\n"
if [ $(md5sum $(dirname $0)/../resources/dbsnp_151.common.hg38.vcf.gz | cut -f1 -d " ") = "a274dcecff9cfe6084eaef848080ad8d" ] && [ $(md5sum $(dirname $0)/../resources/dbsnp_151.common.hg38.vcf.gz.tbi | cut -f1 -d " ") = "e924bba7bb127725fdb7e882dde6109e" ]
then
    echo "Checksum OK."
else
    rm -f $(dirname $0)/resources/hg38.gc50Base.wig.gz
    echo "Checksum failed. Try downloading again."
fi
