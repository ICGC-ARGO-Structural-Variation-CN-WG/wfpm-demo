wget -O $(dirname $0)/../singularity/facets.v1.sif "https://campuscloud.unibe.ch/rest/files/public/links/02dc805579e4ac80017a14e3015f6d44?passKey=63996441394817211&shareId=45371"

echo -e "Checking file integrity.\n"
if [ $(md5sum $(dirname $0)/../singularity/facets.v1.sif | cut -f1 -d " ") = $( cut -f1 -d " " $(dirname $0)/../singularity/facets.v1.sif.md5) ]
then
    echo "Checksum OK."
else
    rm -f $(dirname $0)/../singularity/facets.v1.sif
    echo "Checksum failed. Try downloading again."
fi
