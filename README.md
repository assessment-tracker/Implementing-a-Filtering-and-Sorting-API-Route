# Fetch Blog Posts
### Note: Please read all the instructions before starting the assessment.
## Part 1: Fetching Blog Posts

Implement a route for fetching blog posts by `authorIds`. Please ensure that only a logged in **User** can use this new route.

The route should:

* Fetch blog posts that have at least one of the authors specified in the `authorIds` parameter in the request. **Note**: a helper function for fetching blog posts by a single author have been provided for you to use: `Post.getPostsByUserId`.
* Sort the blog posts based on the provided query parameters (outlined below) and remove any duplicate blog posts (try to be efficient when doing this).
* Return the blog posts in the response.

Your route should exactly match the following specification for the request and responses. Note that the data returned from the database may need to be modified to match the expected response format.

### Request

* **Route**: `/api/posts`
* **Method**: `GET`
* **Query Parameters**:
    * `authorids`:
        * **Type**: String (required)
        * **Description**: A comma separated list of integer user IDs.
        * **Default value**: N/A
        * **Example value**: `"1,5"`
    * `sortBy`:
        * **Type**: String (optional)
        * **Description**: The field to sort the blog posts by. The only acceptable values for this parameter are: `id`, `reads`, `likes`, `popularity`.
        * **Default value**: `"id"`
        * **Example value**: `"popularity"`
    * `direction`:
        * **Type**: String (optional)
        * **Description**: The direction for sorting. The only acceptable values for this parameter are: `asc`, `desc`.
        * **Default value**: `"asc"`
        * **Example value**: `"desc"`

### Success Response

If the request was formed correctly, a success response containing a JSON payload should be returned.

All the properties of `Post` should be returned in the response in the format specified below:

**Response Status Code**: `200`

**Response Body (JSON)**:

```json
{
  "posts": [
    {
      "id": 1,         # number
      "likes": 960,    # number
      "popularity": 0.13, # number
      "reads": 50361,  # number
      "tags": ["tech", "health"], # array of strings
      "text": "Some text here." # string
    }
  ]
}
```

### Error Response

Your route implementation should include error handling. When designing your implementation, think about what edge cases you need to handle and what error messages would be helpful. An example of error handling is verifying the format of the query parameters and that the user is allowed to perform this action. Your error responses should match the provided response format below:

**Response Status Code**: Use REST best practices when determining which status code to use

**Response Body (JSON)**:

```json
{
  "error": "<error message>"
}
```
## Part 2: Written Evaluation

Please provide a markdown file with the answers to the following questions below.

The product team has decided that we want to make a change to this application such that authors of a blog post can have different roles:

Authors can be owners, editors, or viewers of a blog post. For any blog post, there must always be at least one owner of the blog post. Only owners of a blog post can modify the authors' list to a blog post (adding more authors, changing their role).

### Questions:

1.  What database changes would be required to the starter code to allow for different roles for authors of a blog post? Imagine that we'd want to also be able to add custom roles and change the permission sets for certain roles on the fly without any code changes.

2.  What considerations would need to be made for both fetching and editing blog posts given these changes? What edge cases might need to be considered?

### Considerations

Please format your answers so that they are easy to digest, and do not include any code in your pull request related to these questions above. We will be evaluating both the quality of your answer as well as the quality of your written explanation of that answer.

Please include a file in the root of the repo called `roles-proposal.md` that addresses these questions.

# Submitting Your Solution

Open a pull request from `dev` into `main` once you are ready to submit. Do not merge the pull request. Here is a step-by-step guide on how to create a pull request.

# Getting Started

- System requirements
  - Node.JS v18
- Set environment variables: create a `.env` file in the root directory, and copy the contents from [.env.sample](.env.sample)
- Install dependencies
  ```
  yarn
  ```
- Seed database
  ```
  yarn seed
  ```
- Start the dev server
  ```
  yarn dev
  ```

# Getting Started (Docker)

Instead of following the steps above, you can also use Docker to set up your environment.

- System requirements
  - [Docker Compose](https://docs.docker.com/compose/install/)
- Run `docker-compose up` to spin up the dev server.
- Enter `Ctrl-C` in the same same terminal or `docker-compose down` in a separate terminal to shut down the server.

# Verify That Everything Is Set Up Correctly

You can use cURL or a tool like [Postman](https://www.postman.com/) to test the API.

#### Example Curl Commands

You can log in as one of the seeded users with the following curl command:

```bash
curl --location --request POST 'localhost:8080/api/login' \
--header 'Content-Type: application/json' \
--data-raw '{
    "username": "thomas",
    "password": "123456"
}'
```

Then you can use the token that comes back from the /login request to make an authenticated request to create a new blog post

```bash
curl --location --request POST 'localhost:8080/api/posts' \
--header 'x-access-token: your-token-here' \
--header 'Content-Type: application/json' \
--data-raw '{
    "text": "This is some text for the blog post...",
    "tags": ["travel", "hotel"]
}'
```

# Helpful Commands

- `yarn lint` : Runs linter.
- `yarn prettier --write .` : Runs autoformatter
- `yarn test` : This repository contains a non-comprehensive set of unit tests used to determine if your code meets the basic requirements of the assignment. **Please do not modify these tests.**
- `yarn seed` : Resets database and populates it with sample data.

# Common Setup Errors

- If you encounter an error related to `secretOrPrivateKey` when attempting to make a request, please ensure you have created a .env file in the root directory as per the _Getting Started_ instructions.
- If you are on M1 mac, you might encounter `ERR_DLOPEN_FAILED` when you try to install dependencies locally then run the server in docker (or vice versa). In case of error, try removing the `node_modules` directory and restart `docker compose up`.
