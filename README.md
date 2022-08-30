#  Building Clima requires that you have an OpenWeatherMap API key stored within a Secrets.xcconfig file within your project. Make sure you have your API key stored within a Secrets.xcconfig file before running your app.
Create a file called Secrets.xcconfig in the root directory of your project. Add the following to the file:
OpenWeatherMapAPIKey = <API key goes here>

#  Add Secrets.xcconfig to your repo's .gitignore to prevent it (or other secrets you may have in your app) from being committed to GitHub.