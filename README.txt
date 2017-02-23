This is an app to list admins in Canvas by subaccount, their last known activity, and their contact info. There are two endpoints. 

The first is the main root URL ('/') which retrieves a list of subaccounts from the Canvas API. The other retrieves a list of admins and their data for a specified school (subaccount) ID and renders a partial view which is a table of this information.

After the main page loads, the javascript in main.js makes AJAX calls to the second endpoint and asynchronously loads the admins and their data. This is all done through the canvas_api helper provided by the wolf_core gem. The API requests are cached for one hour by default, and the data for each admin is retrieved in parallel. Beware that this can be finicky if the server is not configured to handle many requests at the same time (i.e. You will DOS yourself with your own ajax requests). This can be easily changed to run in a loop rather than in parallel, it will just increase the page load time.

All routes require authentication through Canvas (see sinatra-canvas_auth gem) and only Admin and HelpDesk roles are permitted access.
