# using this repository

```
git clone https://github.com/lblod/frontend-berichten-intern 
git clone http://github.com/lblod/batch-inzendingen-service
git clone https://github.com/lblod/app-berichtencentrum-intern
pushd lblod/batch-inzendingen-service
docker build -t lblod/batch-inzendingen-service .
popd
pushd app-berichtencentrum-intern
drc up -d
popd
pushd frontend-berichten-intern
edi npm install
eds --proxy http://host
popd
```
1. Open http://localhost:4200
2. Upload a **CSV** with the following headers `Dossiernummer,Type communicatie,Betreft,Afdeling/Team,bestuur,BestuurseenheidURI,Datum verzending,Bijlagen
` Make sure all columns are filled.
3. Refresh and upload the files to the messages
4. Run ./build-migration.sh to create zip with files and migration files
