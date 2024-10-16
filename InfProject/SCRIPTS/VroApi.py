import requests
import re
import pandas

# The simple REST API client for MatInf VRO API
class MatInfWebApiClient:
    def __init__(self, service_url, api_key):
        self.service_url = service_url + "/vroapi/v1/"
        self.api_key = api_key
        self.file_name=""
        self.dataframe=None

    def getFilename_fromCd(self, cd):
        if not cd:
            return None
        fname = re.findall('filename=(.+)(?:;.+)', cd)
        if len(fname) == 0:
            return None
        self.file_name=fname[0]
        return fname[0]

    def get_headers(self):
        return { 'VroApi': self.api_key }

    def execute(self, sql):
        headers = self.get_headers()
        data = { 'sql': sql }
        try:
            response = requests.post(self.service_url+"execute", headers=headers, data=data)
            response.raise_for_status()  # Raise exception for non-2xx status codes
            js = response.json()
            self.dataframe = pandas.DataFrame.from_dict(js)
            return js
        except requests.exceptions.RequestException as e:
            print(f"Error: {e}")
            return None

    def download(self, id, file_name=None):
        headers = self.get_headers()
        data = { 'id': id }
        try:
            response = requests.get(self.service_url+"download", params=data, headers=headers)
            response.raise_for_status()  # Raise exception for non-2xx status codes

            self.file_name=file_name
            if not file_name:
                file_name = self.getFilename_fromCd(response.headers.get('content-disposition'))
                #print('extracted file_name: ' + self.file_name)
            open(file_name, 'wb').write(response.content)
            return response

        except requests.exceptions.RequestException as e:
            print(f"Error: {e}")
            return None


# Example usage:
if __name__ == "__main__":
    # initialise service_url (tenant main url)
    tenant_url = "https://..." # tenant_url here

    # initialise api_key (corresponding VroApi claim must be associated with a user in database)
    api_key = "email_key" # your_api_key here

    client = MatInfWebApiClient(tenant_url, api_key)

    result = client.execute("select * from vroTypeInfo")
    if result:
        print("API Response(execute):", result)
        print("API Response(execute): ", client.dataframe)

    result = client.download(43511)	# ObjectId
    if result:
        print(f"API Response(download, {client.file_name}):", result)
