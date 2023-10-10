import openai
import sys
import os

def chat_with_openai(api_key, message, file_path):
    # Set the OpenAI API key
    openai.api_key = api_key

    # Ensure the directory structure exists for tracking tries
    tries_directory = os.path.dirname(f'tries_{file_path}.txt')
    os.makedirs(tries_directory, exist_ok=True)

    # Check if the maximum tries for this file path have been exceeded
    tries_file_path = f'tries_{file_path}.txt'
    if not os.path.exists(tries_file_path):
        with open(tries_file_path, 'w') as f:
            f.write('0')
    with open(tries_file_path, 'r') as f:
        tries = int(f.read())
        if tries >= 3:
            print(f"Maximum tries exceeded for '{file_path}'")
            return

    # Extract content from the file with the provided file_path + ".txt"
    full_file_path = file_path + ".txt"
    if os.path.exists(full_file_path):
        with open(full_file_path, "r") as file:
            file_contents = file.read()
    else:
        print(f"File not found: {full_file_path}")
        return

    # Combine the file contents and user message as the prompt for ChatGPT
    prompt = f"{file_contents}\nUser: {message}"

    # Use the combined prompt for ChatGPT
    response = openai.Completion.create(
        engine="text-davinci-002",  # Replace with your preferred ChatGPT engine
        prompt=prompt,
        max_tokens=100,  # Adjust token limit as needed
    )

    bot_response = response.choices[0].text.strip()
    print(f"Bot response for '{full_file_path}' ('{message}'): {bot_response}")

    # Increment the tries count for this file path
    tries += 1
    with open(tries_file_path, 'w') as f:
        f.write(str(tries))

# Example usage
if __name__ == "__main__":
    if len(sys.argv) != 3:
        print("Usage: python chat.py <message> <file_path>")
        sys.exit(1)

    api_key = "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"
    message = sys.argv[1]
    file_path = sys.argv[2]

    chat_with_openai(api_key, message, file_path)
