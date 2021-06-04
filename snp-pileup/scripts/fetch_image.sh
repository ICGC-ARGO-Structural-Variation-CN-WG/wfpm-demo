wget -O $(dirname $0)/../images/snp-pileup.v1.sif "https://campuscloud.unibe.ch/rest/files/public/links/02dc80557845cf480179d267e7fb541e?passKey=-5084747719686331344&shareId=45100"

echo -e "Checking file integrity.\n"
if [ $(md5sum $(dirname $0)/../images/snp-pileup.v1.sif | cut -f1 -d " ") = $( cut -f1 -d " " $(dirname $0)/../images/snp-pileup.v1.sif.md5) ]
then
    echo "Checksum OK."
else
    rm -f $(dirname $0)/../images/snp-pileup.v1.sif
    echo "Checksum failed. Try downloading again."
fi
