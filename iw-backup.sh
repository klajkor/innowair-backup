#!/bin/dash
NOW=`date +'%Y.%m.%d %T'`
echo $NOW' Start '$0

# DB_USERNAME=''
# DB_PASSWORD=''
# a jelszo ezentul itt talalhato:
. /etc/innowair-backup-cfg.sh

DB_NAMES="IMLBase_Exicom IMLDBSchema InnoWair_Exicom exicom ExicomKonvert"
INNOWAIR_ROOT='/var/www/html'
INNOWAIR_DIR1=$INNOWAIR_ROOT/amfphp
INNOWAIR_DIR2=$INNOWAIR_ROOT/download
INNOWAIR_DIR3=$INNOWAIR_ROOT/exicom
INNOWAIR_DIR4=$INNOWAIR_ROOT/portalcommon
INNOWAIR_DIR5=$INNOWAIR_ROOT/uploads
BACKUP_ROOT='/var/backups'
BACKUP_ROOT_INNOWAIR=$BACKUP_ROOT/innowair
BACKUP_ROOT_INNOWAIR_TMP=$BACKUP_ROOT/innowair/tmp
BACKUP_ROOT_INNOWAIR_TMP_DB=$BACKUP_ROOT/innowair/tmp_db
BACKUP_ROOT_INNOWAIR_TMP1=$BACKUP_ROOT_INNOWAIR_TMP/amfphp
BACKUP_ROOT_INNOWAIR_TMP2=$BACKUP_ROOT_INNOWAIR_TMP/download
BACKUP_ROOT_INNOWAIR_TMP3=$BACKUP_ROOT_INNOWAIR_TMP/exicom
BACKUP_ROOT_INNOWAIR_TMP4=$BACKUP_ROOT_INNOWAIR_TMP/portalcommon
BACKUP_ROOT_INNOWAIR_TMP5=$BACKUP_ROOT_INNOWAIR_TMP/uploads

DATE_STR=`date +%Y%m%d_%H%M`
FB_FILES_FILENAME='innowair_backup_'${DATE_STR}'_files.tar.gz'
FB_DB_FILENAME='innowair_backup_'${DATE_STR}'_db.tar.gz'

BACKUP_TARGET=/mnt/backupshare/innowair/

KEEP_DAYS=7

NOW=`date +'%Y.%m.%d %T'`
echo $NOW' Fájlszerver csatlakoztatas ellenorzese'
MOUNT_CHECK=`mount|grep linuxbackup|wc -l`
if [ $MOUNT_CHECK -gt 0 ]
then
	NOW=`date +'%Y.%m.%d %T'`
	echo $NOW' OK'
else
	NOW=`date +'%Y.%m.%d %T'`
	echo $NOW' Nincs csatlakoztatva a fajlszerver, KILEPEK!'
	exit 1
fi
	
NOW=`date +'%Y.%m.%d %T'`
echo $NOW' Alkonyvtarak ellenorzese'
mkdir $BACKUP_ROOT -p
mkdir $BACKUP_ROOT_INNOWAIR -p
rm -rf $BACKUP_ROOT_INNOWAIR_TMP/db
rm -rf $BACKUP_ROOT_INNOWAIR_TMP/_db
mkdir $BACKUP_ROOT_INNOWAIR_TMP/_db -p
rm -rf $BACKUP_ROOT_INNOWAIR_TMP_DB
mkdir $BACKUP_ROOT_INNOWAIR_TMP_DB -p
rm -rf $BACKUP_ROOT_INNOWAIR_TMP1
mkdir $BACKUP_ROOT_INNOWAIR_TMP1 -p
rm -rf $BACKUP_ROOT_INNOWAIR_TMP2
mkdir $BACKUP_ROOT_INNOWAIR_TMP2 -p
rm -rf $BACKUP_ROOT_INNOWAIR_TMP3
mkdir $BACKUP_ROOT_INNOWAIR_TMP3 -p
rm -rf $BACKUP_ROOT_INNOWAIR_TMP4
mkdir $BACKUP_ROOT_INNOWAIR_TMP4 -p
rm -rf $BACKUP_ROOT_INNOWAIR_TMP5
mkdir $BACKUP_ROOT_INNOWAIR_TMP5 -p
mkdir $BACKUP_ROOT_INNOWAIR/full -p

NOW=`date +'%Y.%m.%d %T'`
echo $NOW' A '$KEEP_DAYS' napnal regebbi helyi mentesek torlese'
find $BACKUP_ROOT_INNOWAIR/full -mtime +$KEEP_DAYS -exec rm {} \;

NOW=`date +'%Y.%m.%d %T'`
echo $NOW' Adatbazisok mentese'
for db_name in $DB_NAMES
do
	NOW=`date +'%Y.%m.%d %T'`
	echo $NOW' '$db_name
	/usr/bin/mysqldump -u $DB_USERNAME --password=$DB_PASSWORD $db_name | gzip > $BACKUP_ROOT_INNOWAIR_TMP_DB/${db_name}_`date +%Y%m%d_%H%M`.sql.gz
done


NOW=`date +'%Y.%m.%d %T'`
echo $NOW' Portal fajlok es mellekletek mentese'
rsync -a $INNOWAIR_DIR1/ $BACKUP_ROOT_INNOWAIR_TMP1/
rsync -a $INNOWAIR_DIR2/ $BACKUP_ROOT_INNOWAIR_TMP2/
rsync -a $INNOWAIR_DIR3/ $BACKUP_ROOT_INNOWAIR_TMP3/
rsync -a $INNOWAIR_DIR4/ $BACKUP_ROOT_INNOWAIR_TMP4/
rsync -a $INNOWAIR_DIR5/ $BACKUP_ROOT_INNOWAIR_TMP5/

NOW=`date +'%Y.%m.%d %T'`
echo $NOW' Fajlok csomagolasa egy archiv fájlba '$BACKUP_ROOT_INNOWAIR/full/$FB_FILES_FILENAME
cd $BACKUP_ROOT_INNOWAIR_TMP
tar -czf $BACKUP_ROOT_INNOWAIR/full/$FB_FILES_FILENAME ./

NOW=`date +'%Y.%m.%d %T'`
echo $NOW' Adatbazisok csomagolasa egy archiv fájlba '$BACKUP_ROOT_INNOWAIR/full/$FB_DB_FILENAME
cd $BACKUP_ROOT_INNOWAIR_TMP_DB
tar -czf $BACKUP_ROOT_INNOWAIR/full/$FB_DB_FILENAME ./

NOW=`date +'%Y.%m.%d %T'`
echo $NOW' rsync a windows fajl szerverre'
rsync -avz $BACKUP_ROOT_INNOWAIR/full/ $BACKUP_TARGET
cd $BACKUP_ROOT_INNOWAIR_TMP
rsync -avz $0 $BACKUP_TARGET

NOW=`date +'%Y.%m.%d %T'`
echo $NOW' Backup vege'

