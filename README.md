To run the script, make sure the database .sql dump file is present in the same directory with the backup archieve or in the backup itself 
Usage: 1) Upload restore.sh script to the directory where the backup should be restored 
2) Navigate to the directory with cd command: ex. cd public_html 
3) run: bash restore.sh backupfilename sql_dump_file; ex.: bash restore.sh backup.zip database.sql 
Supported formats:
1) Files: .tar, .zip, .tar.gz
2) Database: .sql, .sql.tar
