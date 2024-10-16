rem curl -v -X POST "https://localhost:7100/vroapi/v1/execute" -H "VroApi: VroApiValue" -H "Content-Type: application/x-www-form-urlencoded" -d "sql=select * from vroTypeInfo"
curl -X POST "https://localhost:7100/vroapi/v1/execute" -H "VroApi: VroApiValue" -H "Content-Type: application/x-www-form-urlencoded" -d "sql=select * from vroTypeInfo" --output VroApi_Execute.json

