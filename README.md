# Export All Organization Repositories

This script is designed to export all repositories from a specified GitHub organization using REST API and pagination. 

It was inspired by the GitHub Community discussion "[How To Use Pagination With GitHub's API #69826"](https://github.com/orgs/community/discussions/69826).

## Usage

Run the script in your terminal and when prompted, enter the name of the organization you wish to query::

```bash
bash run_discovery.sh
Please enter the organization name:
My-Super-Cool-ORG
```

## Requirements

- Ensure you have a GitHub API token set in your environment:

```bash
export TOKEN=ghp_**********
```

Visit [GitHub's documentation on Rate Limits](https://docs.github.com/en/graphql/overview/rate-limits-and-node-limits-for-the-graphql-api) to choose the best authentication method for your use case.

- The script requires the following minimum scopes: ```repo```, ```read:org```.

## Important Notes

- The delay between API calls is hardcoded to ```6 seconds``` to comply with rate limits.
- Page progress is printed to the screen during discovery.
- This script makes use of the ```jq``` command-line JSON processor to parse API responses. Ensure it is installed on your system.

## Script Details

The script performs the following steps:

1. Checks if the GitHub API token is set in the ```TOKEN``` environment variable.
2. Prompts the user to enter the organization's name.
3. Constructs the API URL for querying the organization's repositories.
4. Iterates through all pages of the API response, adding repository names to an array.
5. Checks for the presence of a "next page" in the API response to continue pagination.
6. Prints the number of discovered repositories and location of output for use in next scripts.

## Example Output

```bash
$ bash run_discovery.sh 
Please enter the organization name: 
My-Super-Cool-ORG

Discovering Repo Listing Standby: 

link: <https://api.github.com/organizations/123456789/repos?per_page=100&page=2>; rel="next", <https://api.github.com/organizations/123456789/repos?per_page=100&page=2>; rel="last"

Discovering Repo Listing Standby: 

link: <https://api.github.com/organizations/123456789/repos?per_page=100&page=1>; rel="prev", <https://api.github.com/organizations/123456789/repos?per_page=100&page=1>; rel="first"

Discovered Repository Count: 142
Repo Listing located in: /tmp/2024-01-20_10-15_discovered_repositories.tmp
```

## License

This script is released under [MIT License](LICENSE).
