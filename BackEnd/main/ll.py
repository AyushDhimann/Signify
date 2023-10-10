import time
from pprint import pprint
from dropbox_sign import ApiClient, ApiException, Configuration, apis, models
import sys
import os

# Define a function to create the Dropbox Sign API client
def create_api_client(api_key, client_id, file_path):
    configuration = Configuration(username=api_key)
    api_client = ApiClient(configuration)
    signature_request_api = apis.SignatureRequestApi(api_client)
    
    signer_1 = models.SubSignatureRequestSigner(
        email_address="kitankitana905@gmail.com",
        name="Your Name",
        order=0,
    )
    
    signing_options = models.SubSigningOptions(
        draw=True,
        type=True,
        upload=True,
        phone=True,
        default_type="draw",
    )
    
    data = models.SignatureRequestCreateEmbeddedRequest(
        client_id=client_id,
        title="Document by Signify",
        subject="Document by Signify",
        message="Please sign this to carry on your signing process with Signify",
        signers=[signer_1],
        cc_email_addresses=["kitankitana905@gmail.com"],
        files=[open(file_path, "rb")],
        signing_options=signing_options,
        test_mode=True,
    )
    
    return api_client, signature_request_api, data

# Define a function to create the file URL
def create_file_url(final_url, lol4):
    input_file_name = lol4
    directory, filename = os.path.split(input_file_name)
    second_file_path = os.path.join(directory, filename + ".part1")

    with open(second_file_path, 'w') as file:
        file.write(final_url)

    return second_file_path

# Define a function to check the signature request status
def check_signature_request_status(api_key, signaturerequestid):
    configurationn = Configuration(username=api_key)
    
    with ApiClient(configurationn) as api_client:
        signature_request_api = apis.SignatureRequestApi(api_client)
        x = 0
        
        while x <= 240:
            try:
                response = signature_request_api.signature_request_get(signaturerequestid)
                if response.signature_request.is_complete:
                    break
                elif response.signature_request.is_complete is not None and not True and not False:
                    print("Signature request is in an unexpected state.")
                    break
                elif response.signature_request.is_complete is False:
                    time.sleep(3)
                    if x < 20:
                        x += 5
                        print("Signature request is not complete yet. Retrying in 5 seconds...")
                    else:
                        x += 3
                        print("Signature request is not complete yet. Retrying in 3 seconds...")
                else:
                    print("Received an unexpected response. Stopping execution.")
                    break
            except ApiException as e:
                print("Exception when calling Dropbox Sign API: %s\n" % e)
            if x >= 240:
                print("Execution stopped after 18 seconds.")
                break

        if x <= 237:
            try:
                response_file = signature_request_api.signature_request_files_as_file_url(signaturerequestid)
                pprint(response_file.file_url)
                print("Final signature request is complete.")
                send_url = response_file.file_url
                input_file_name2 = lol4
                directory, filename = os.path.split(input_file_name2)
                third_file_path = os.path.join(directory, filename + ".part2")

                with open(third_file_path, 'w') as file:
                    file.write("Final: " + send_url)

            except ApiException as e_file:
                print("Exception when calling Dropbox Sign API for file URL: %s\n" % e_file)
        else:
            print("Dropbox Request Timed out")

# Main function
def main():
    if len(sys.argv) < 2:
        print("Usage: python sign.py <file_path>")
    else:
        file_path = sys.argv[1]
        print("Received file path:", file_path)

    # List of API keys and client IDs
    api_keys_and_clients = [
    ("1f20abb2cd117ca205a5406a67b6beb3df0f99cb7355f3b0f3059edd2aaf506a", "b4b14f2a36ddc60105fd3d75b250eb64"), #ay272
    ("8b35043f628cbeca8214c2437b4e989ca261f203fc2f2bf28f607cc8a1812718", "dff9ee71fd897c266e818c286a3e94fd"),
    ("db41b65cd9dd755bc53892c390066f894c3d81384dcdc60adf3ffb200384c9bb", "472c6e251cf197d133b0c63820dad5c6"),
    ("21e97ac26dd8091a8c81b4d10475a61e2d6784b5271a0fd0645ce82a7276c9ac", "f9fe8f3eb1c5dab51f5e844a2e039272"),
    ("329a870b2a1447978e32e1f7d2236af53423ca9a7edfaaae6dd5b6eac3dbb622", "12dfe30273b12f90b6cb335ec279fb95"),
    ("70ec5a39df89b7cdf8c4f2ed40f33429a832da9aef2e7c61a73ef00c478865e6", "6f27f571079b0214f5359b92eef36468"), #ay844
]

    signaturerequestid = ""
    apiz = ""

    # Iterate through the list of API keys and client IDs
    for api_key, client_id in api_keys_and_clients:
        try:
            api_client, signature_request_api, data = create_api_client(api_key, client_id, file_path)
            apiz = api_key
            response = signature_request_api.signature_request_create_embedded(data)
            signature_id = None

            if 'signature_request' in response:
                signature_id = response.signature_request.signatures[0].signature_id
                client_id = data.client_id
                signaturerequestid = response.signature_request.signature_request_id
                print(f"Signature Request ID: {response.signature_request.signature_request_id}")
                print(f"Signature ID: {signature_id}")

                embedded_api = apis.EmbeddedApi(api_client)

                try:
                    response = embedded_api.embedded_sign_url(signature_id)
                    break  # Exit the loop if a working set is found
                except ApiException as e:
                    print("Exception when calling Dropbox Sign API (Embedded Sign URL): %s\n" % e)
            else:
                print("Error: Signature request data not found in the response.")
        except ApiException as e:
            print(f"Exception when calling Dropbox Sign API (Signature Request) with API key {api_key}: {e}\n")

    if signature_id is not None:
        user_culture = "en_US"
        parent_url = "http%3A%2F%2F143.244.158.53%2Flol.html"
        skip_domain_verification = "1"
        js_version = "2.0.0"

        final_url = (
            f"{response['embedded']['sign_url']}&"
            f"client_id={client_id}&"
            f"debug=0&"
            f"user_culture={user_culture}&"
            f"parent_url={parent_url}&"
            f"skip_domain_verification={skip_domain_verification}&"
            f"js_version={js_version}"
        )

        print(final_url)

        second_file_path = create_file_url(final_url, file_path)

    else:
        print("Signature ID not available, unable to proceed.")

    check_signature_request_status(apiz, signaturerequestid)

if __name__ == "__main__":
    main()
