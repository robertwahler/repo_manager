@announce
Feature: Listing assets

  Assets can be listed to the screen in html or plain text

  Example usage:

    basic_app list
    basic_app list --type=asset_type
    basic_app list --tags=adventure,favorites  --sort=ACQUIRED
    basic_app list --format=HTML >> tmp/aruba/index.html

 Background: A master configuration file
    Given a file named "basic_app.conf" with:
      """
      ---
      options:
        color  : true
      folders:
        user   : data
      """

  Scenario: Invalid asset type
    When I run `basic_app list --type=invalid_asset_type`
    Then the exit status should be 1
    And the output should contain:
      """
      unknown asset type
      """

  Scenario: List all
    Given the folder "data/app_assets" with the following asset configurations:
      | name         |
      | asset1       |
      | asset2       |
      | asset3       |
    When I run `basic_app list --type=app_asset`
    Then the exit status should be 0
    And the output should contain:
      """
      asset1:
      --- {}
      asset2:
      --- {}
      asset3:
      --- {}
      """

  Scenario: List just name
    Given the folder "data/app_assets" with the following asset configurations:
      | name         |
      | asset1       |
      | asset2       |
      | asset3       |
    When I run `basic_app list --list=NAME --type=app_asset`
    Then the exit status should be 0
    And the output should contain:
      """
      asset1
      asset2
      asset3
      """

  Scenario: List to screen using the built in default template
    Given the folder "data/app_assets" with the following asset configurations:
      | name         |
      | asset1       |
      | asset2       |
      | asset3       |
    When I run `basic_app list --template  --type=app_asset --verbose`
    Then the exit status should be 0
    And the output should contain:
      """
      <!DOCTYPE html>
      <html lang="en">
        <head>
          <title>Default View</title>
          <meta charset="utf-8" />
          <meta content="basic_app" name="keywords" />
          <meta content="BasicApp default template" name="description" />
          <meta content="Robert Wahler" name="author" />
          <link href="http://twitter.github.com/bootstrap/1.4.0/bootstrap.min.css" rel="stylesheet" />
          <style type="text/css">html, body {
              background-color: #eee;
            }
            .container {
              width: 820px;
            }
            .container > footer p {
              text-align: center;
            }
            .page-header {
              background-color: #f5f5f5;
              padding: 20px 20px 10px;
              margin: -20px -20px 20px;
            }
            /* The white background content wrapper */
            .content {
              background-color: #fff;
              padding: 20px;
              margin: 0 -20px; /* negative indent the amount of the padding to maintain the grid system */
              -webkit-border-radius: 0 0 6px 6px;
                 -moz-border-radius: 0 0 6px 6px;
                      border-radius: 0 0 6px 6px;
              -webkit-box-shadow: 0 1px 2px rgba(0,0,0,.15);
                 -moz-box-shadow: 0 1px 2px rgba(0,0,0,.15);
                      box-shadow: 0 1px 2px rgba(0,0,0,.15);
            }
            </style>
        </head>
        <body>
          <div class="container">
            <div class="content">
              <div class="page-header">
                <h1>Assets Report</h1>
              </div>
              <h2>Assets</h2>
              <table class="condensed-table bordered-table zebra-striped">
                <thead>
                  <tr>
                    <th>Name</th>
                  </tr>
                </thead>
                <tbody>
                  <tr>
                    <td>asset1</td>
                  </tr>
                  <tr>
                    <td>asset2</td>
                  </tr>
                  <tr>
                    <td>asset3</td>
                  </tr>
                </tbody>
              </table>
            </div>
            <footer>
              <p>Copyright &copy; 2011 GearheadForHire, LLC</p>
            </footer>
          </div>
        </body>
      </html>
      """

  Scenario: List to file using the built in default template
    Given the folder "data/app_assets" with the following asset configurations:
      | name         |
      | asset1       |
      | asset2       |
      | asset3       |
    When I run `basic_app list --template  --type=app_asset --output=data/output.html --verbose`
    Then the exit status should be 0
    And the file "data/output.html" should contain:
      """
      <!DOCTYPE html>
      <html lang="en">
        <head>
          <title>Default View</title>
          <meta charset="utf-8" />
          <meta content="basic_app" name="keywords" />
          <meta content="BasicApp default template" name="description" />
          <meta content="Robert Wahler" name="author" />
          <link href="http://twitter.github.com/bootstrap/1.4.0/bootstrap.min.css" rel="stylesheet" />
          <style type="text/css">html, body {
              background-color: #eee;
            }
            .container {
              width: 820px;
            }
            .container > footer p {
              text-align: center;
            }
            .page-header {
              background-color: #f5f5f5;
              padding: 20px 20px 10px;
              margin: -20px -20px 20px;
            }
            /* The white background content wrapper */
            .content {
              background-color: #fff;
              padding: 20px;
              margin: 0 -20px; /* negative indent the amount of the padding to maintain the grid system */
              -webkit-border-radius: 0 0 6px 6px;
                 -moz-border-radius: 0 0 6px 6px;
                      border-radius: 0 0 6px 6px;
              -webkit-box-shadow: 0 1px 2px rgba(0,0,0,.15);
                 -moz-box-shadow: 0 1px 2px rgba(0,0,0,.15);
                      box-shadow: 0 1px 2px rgba(0,0,0,.15);
            }
            </style>
        </head>
        <body>
          <div class="container">
            <div class="content">
              <div class="page-header">
                <h1>Assets Report</h1>
              </div>
              <h2>Assets</h2>
              <table class="condensed-table bordered-table zebra-striped">
                <thead>
                  <tr>
                    <th>Name</th>
                  </tr>
                </thead>
                <tbody>
                  <tr>
                    <td>asset1</td>
                  </tr>
                  <tr>
                    <td>asset2</td>
                  </tr>
                  <tr>
                    <td>asset3</td>
                  </tr>
                </tbody>
              </table>
            </div>
            <footer>
              <p>Copyright &copy; 2011 GearheadForHire, LLC</p>
            </footer>
          </div>
        </body>
      </html>
      """
