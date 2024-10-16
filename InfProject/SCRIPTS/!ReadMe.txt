# initialise service_url (tenant main url)
service_url = "https://..." # tenant_url here

# initialise api_key (corresponding VroApi claim must be associated with a user in database)
api_key = "email_key" # your_api_key here

# create a simple client object
client = MatInfWebApiClient(service_url, api_key)

# Run arbitrary SQL and get result
result = client.execute("select * from vroTypeInfo")
if result:
    print("API Response(execute):", result)
    print("API Response(execute): ", client.dataframe)
    
# Download any object file by ObjectId
result = client.download(43511)	# ObjectId
if result:
    print(f"API Response(download, {client.file_name}):", result)