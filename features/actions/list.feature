@announce
Feature: Listing assets

  Asset configurations listed to the screen or file with or without templates
  using regular expression (regex) filtering.

  Example usage:

      basic_app list
      basic_app list --list=NAME
      basic_app list --type=asset_type
      basic_app list --template ~/templates/myTemplate.slim

  Example asset regex filtering:

      basic_app list --filter=ass.t1,as.et2

  Equivalent asset filtering:

      basic_app list --filter=asset1,asset2
      basic_app list --asset=asset1,asset2
      basic_app list asset1 asset2

  Equivalent usage, file writing:

     basic_app list --template=default.slim --output=tmp/aruba/index.html
     basic_app list --template=default.slim >> tmp/aruba/index.html

  Example return just the first matching asset

      basic_app list --match=FIRST

  Example fail out if more than one matching asset

      basic_app list --match=ONE

  Example disable regex filter matching

      basic_app list --match=EXACT

  Example future usage (not implemented):

      basic_app list --tags=adventure,favorites --group_by=tags --sort=ACQUIRED

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

  Scenario: List just name using '--filter' option
    Given the folder "data/app_assets" with the following asset configurations:
      | name         |
      | asset1       |
      | asset2       |
      | asset3       |
    When I run `basic_app list --filter=asset1 --list=NAME --type=app_asset`
    Then the exit status should be 0
    And the output should contain:
      """
      asset1
      """
    And the output should not contain:
      """
      asset2
      """
    And the output should not contain:
      """
      asset3
      """

  Scenario: List just name using '--asset' option
    Given the folder "data/app_assets" with the following asset configurations:
      | name         |
      | asset1       |
      | asset2       |
      | asset3       |
    When I run `basic_app list --asset=asset1 --list=NAME --type=app_asset`
    Then the exit status should be 0
    And the output should contain exactly:
      """
      asset1

      """

  Scenario: List just name using passing filters as args
    Given the folder "data/app_assets" with the following asset configurations:
      | name         |
      | asset1       |
      | asset2       |
      | asset3       |
    When I run `basic_app list asset1 asset2 --list=NAME --type=app_asset`
    Then the exit status should be 0
    And the output should contain:
      """
      asset1
      asset2
      """
    And the output should not contain:
      """
      asset3
      """

  Scenario: List the first and only first matching asset with match mode '--match FIRST'
    Given the folder "data/app_assets" with the following asset configurations:
      | name         |
      | asset1       |
      | asset2       |
      | asset3       |
    When I run `basic_app list --match=FIRST --list=NAME --type=app_asset`
    Then the exit status should be 0
    And the output should contain exactly:
      """
      asset1

      """

  Scenario: Multiple matching assets fail hard with asset match mode '--match ONE'
    Given the folder "data/app_assets" with the following asset configurations:
      | name         |
      | asset1       |
      | asset2       |
      | asset3       |
    When I run `basic_app list --match=ONE --list=NAME --type=app_asset`
    Then the exit status should be 1
    And the output should contain:
      """
      multiple matching assets found
      """

  Scenario: Regex asset matching of any part of asset name is the default match mode
    Given the folder "data/app_assets" with the following asset configurations:
      | name         |
      | asset1       |
      | asset2       |
      | asset3       |
    When I run `basic_app list a.s.t --list=NAME --type=app_asset`
    Then the exit status should be 0
    And the output should contain:
      """
      asset1
      asset2
      asset3
      """

  Scenario: No regex asset matching with asset match mode '--match EXACT'
    Given the folder "data/app_assets" with the following asset configurations:
      | name         |
      | asset1       |
      | asset2       |
      | asset3       |
    When I run `basic_app list a.s.t --match=EXACT --list=NAME --type=app_asset`
    Then the exit status should be 0
    And the output should not contain:
      """
      asset1
      """

  Scenario: List to screen using the built in default template
    Given the folder "data/app_assets" with the following asset configurations:
      | name         |
      | asset1       |
      | asset2       |
      | asset3       |
    When I run `basic_app list --template  --type=app_asset --verbose`
    Then the exit status should be 0
    And the normalized output should contain:
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

  Scenario: No not overwrite existing output unless prompted 'Y/N' or given the '--force' option
    Given the folder "data/app_assets" with the following asset configurations:
      | name         |
      | asset1       |
      | asset2       |
      | asset3       |
    And a file named "data/output.html" with:
      """
      this file was not overwritten
      """
    When I run `basic_app list --template  --type=app_asset --output=data/output.html --verbose`
    Then the exit status should be 0
    And the file "data/output.html" should contain:
      """
      this file was not overwritten
      """
    And the file "data/output.html" should not contain:
      """
      </html>
      """

  Scenario: Overwrite automatically for existing output using '--force'
    Given the folder "data/app_assets" with the following asset configurations:
      | name         |
      | asset1       |
      | asset2       |
      | asset3       |
    And a file named "data/output.html" with:
      """
      this file was not overwritten
      """
    When I run `basic_app list --template  --type=app_asset --output=data/output.html --force --verbose`
    Then the exit status should be 0
    And the file "data/output.html" should not contain:
      """
      this file was not overwritten
      """
    And the file "data/output.html" should contain:
      """
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

  Scenario: Default action, no filter, --listing==SHORT
    Given a file named "repo.conf" with:
      """
      ---
      repos:
        test1:
          path: test_path_1
        test2:
          path: test_path_2
      """
    When I run `repo list --listing=SHORT`
    Then the exit status should be 0
    And the output should contain:
      """
      test1: test_path_1
      test2: test_path_2
      """

  Scenario: Default action, no filter, --listing=NAME
    Given a file named "repo.conf" with:
      """
      ---
      repos:
        test1:
          path: test_path_1
        test2:
          path: test_path_2
      """
    When I run `repo list --listing=NAME`
    Then the exit status should be 0
    And the output should contain:
      """
      test1
      test2
      """

  Scenario: Default action, no filter, --listing=PATH
    Given a file named "repo.conf" with:
      """
      ---
      repos:
        test1:
          path: test_path_1
        test2:
          path: test_path_2
      """
    When I run `repo list --listing=PATH`
    Then the exit status should be 0
    And the output should contain:
      """
      test_path_1
      test_path_2
      """

  Scenario: Missing path defaults to repo name
    Given a file named "repo.conf" with:
      """
      ---
      repos:
        test1:
        test2:
          path: test2
      """
    When I run `repo list --listing=SHORT`
    Then the exit status should be 0
    And the output should contain:
      """
      test1: test1
      test2: test2
      """

  Scenario: Missing repos is still valid
    Given a file named "repo.conf" with:
      """
      ---
      repos:
      """
    When I run `repo list --listing=SHORT`
    Then the exit status should be 0

  Scenario: Remotes short format with --filter repo
    Given a file named "repo.conf" with:
      """
      ---
      repos:
        test1:
          path: test1
          remotes:
            origin: ./remotes/test1.git
        test2:
          path: test2
      """
    When I run `repo list --filter=test1 --listing=SHORT --no-verbose`
    Then the exit status should be 0
    And the output should contain exactly:
      """
      test1: test1

      """

  Scenario: Remotes short format with arg repo
    Given a file named "repo.conf" with:
      """
      ---
      repos:
        test1:
          path: test1
          remotes:
            origin: ./remotes/test1.git
        test2:
          path: test2
      """
    When I run `repo list test1 --listing=SHORT --no-verbose`
    Then the output should contain exactly:
      """
      test1: test1

      """

  Scenario: Remotes long format
    Given a file named "repo.conf" with:
      """
      ---
      repos:
        test1:
          path: test1
          remotes:
            origin: ./remotes/test1.git
        test2:
          path: test2
      """
    When I run `repo list`
    And the output should match:
      """
      test1:
      .*
      :remotes:.
        :origin: ./remotes/test1.git
      """
