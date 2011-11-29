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
    Then the output should contain:
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
    Then the output should contain:
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
    Then the output should contain:
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
    Then the output should contain:
      """
      <!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">
      <html>
        <head>
          <title>Default View</title>
          <meta content="basic_app" name="keywords" />
        </head>
        <body>
          <h1>Default Title</h1>
          <div id="content">
            <table>
              <thead>
                <tr>
                  <td>Name</td>
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
          <div id="footer">Copyright &copy; 2011 GearheadForHire, LLC</div>
        </body>
      </html>
      """

  @wip
  Scenario: List to file using the built in default template
    Given the folder "data/app_assets" with the following asset configurations:
      | name         |
      | asset1       |
      | asset2       |
      | asset3       |
    When I run `basic_app list --template  --type=app_asset --output=data/output.html --verbose`
    Then the file "data/output.html" should contain:
      """
      <!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">
      <html>
        <head>
          <title>Default View</title>
          <meta content="basic_app" name="keywords" />
        </head>
        <body>
          <h1>Default Title</h1>
          <div id="content">
            <table>
              <thead>
                <tr>
                  <td>Name</td>
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
          <div id="footer">Copyright &copy; 2011 GearheadForHire, LLC</div>
        </body>
      </html>
      """
