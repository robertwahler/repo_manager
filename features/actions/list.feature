@announce
Feature: Listing repos

  repo configurations listed to the screen or file with or without templates
  using regular expression (regex) filtering.

  Example usage:

      repo list
      repo list --list=NAME
      repo list --type=repo_type
      repo list --template ~/templates/myTemplate.slim

  Example repo regex filtering:

      repo list --filter=ass.t1,as.et2

  Equivalent repo filtering:

      repo list --filter=repo1,repo2
      repo list --repo=repo1,repo2
      repo list repo1 repo2

  Equivalent usage, file writing using Slim templates:

     repo list --template=default.slim --output=tmp/aruba/index.html
     repo list --template=default.slim >> tmp/aruba/index.html

  Equivalent usage, file writing using ERB templates:

     repo list --template=default.erb --output=tmp/aruba/index.html
     repo list --template=default.erb >> tmp/aruba/index.html

  Example return just the first matching asset

      repo list --match=FIRST

  Example fail out if more than one matching asset

      repo list --match=ONE

  Example disable regex filter matching

      repo list --match=EXACT

  Example future usage (not implemented):

      repo list --tags=adventure,favorites --group_by=tags --sort=ACQUIRED

  Background: A master configuration file
    Given a file named "repo.conf" with:
      """
      ---
      options:
        color       : true
      folders:
        repos  : data/app_assets
      """

  Scenario: List all
    Given the folder "data/app_assets" with the following asset configurations:
      | name         |
      | asset1       |
      | asset2       |
      | asset3       |
    When I run `repo list`
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
    When I run `repo list --list=NAME`
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
    When I run `repo list --filter=asset1 --list=NAME`
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

  Scenario: List just name using '--repos' option
    Given the folder "data/app_assets" with the following asset configurations:
      | name         |
      | asset1       |
      | asset2       |
      | asset3       |
    When I run `repo list --repos=asset1 --list=NAME`
    Then the exit status should be 0
    And the output should contain exactly:
      """
      asset1

      """

  Scenario: List with invalid options in varying positions on the command line
    When I run `repo list --bad-option1 --repos=asset1 --list=NAME`
    Then the exit status should be 1
    And its output should contain:
      """
      invalid option: --bad-option1
      """
    When I run `repo list arg1 arg2 --bad-option2 --repos=asset1 --list=NAME`
    Then the exit status should be 1
    And its output should contain:
      """
      invalid option: --bad-option2
      """
    When I run `repo --bad-option3 list arg1 arg2 --repos=asset1 --list=NAME`
    Then the exit status should be 1
    And its output should contain:
      """
      invalid option: --bad-option3
      """

  Scenario: List just name using passing filters as args
    Given the folder "data/app_assets" with the following asset configurations:
      | name         |
      | asset1       |
      | asset2       |
      | asset3       |
    When I run `repo list asset1 asset2 --list=NAME`
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
    When I run `repo list --match=FIRST --list=NAME`
    Then the exit status should be 0
    And the output should contain exactly:
      """
      asset1

      """

Scenario: List with invalid options in varying positions on the command line
    When I run `repo list --bad-option1 --repos=asset1 --list=NAME`
    Then the exit status should be 1
    And its output should contain:
      """
      invalid option: --bad-option1
      """
    When I run `repo list arg1 arg2 --bad-option2 --repos=asset1 --list=NAME`
    Then the exit status should be 1
    And its output should contain:
      """
      invalid option: --bad-option2
      """
    When I run `repo --bad-option3 list arg1 arg2 --repos=asset1 --list=NAME`
    Then the exit status should be 1
    And its output should contain:
      """
      invalid option: --bad-option3
      """

  Scenario: Multiple matching assets fail hard with asset match mode '--match ONE'
    Given the folder "data/app_assets" with the following asset configurations:
      | name         |
      | asset1       |
      | asset2       |
      | asset3       |
    When I run `repo list --match=ONE --list=NAME`
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
    When I run `repo list a.s.t --list=NAME`
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
    When I run `repo list a.s.t --match=EXACT --list=NAME`
    Then the exit status should be 0
    And the output should not contain:
      """
      asset1
      """

  Scenario: Matching only on the asset name, not the path
    Given the folder "data/app_assets" with the following asset configurations:
      | name         |
      | asset1       |
      | asset2       |
      | asset3       |
    When I run `repo list app_assets --list=NAME`
    Then the exit status should be 0
    And the output should not contain:
      """
      asset
      """

  Scenario: List to screen using the built in default template
    Given the folder "data/app_assets" with the following asset configurations:
      | name         |
      | asset1       |
      | asset2       |
      | asset3       |
    When I run `repo list --template --verbose`
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
    When I run `repo list --template --output=data/output.html --verbose`
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
    When I run `repo list --template --output=data/output.html --verbose`
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
    When I run `repo list --template --output=data/output.html --force --verbose`
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


  Scenario: Use built in ERB template instead of the default Slim template
    Given the folder "data/app_assets" with the following asset configurations:
      | name         |
      | asset1       |
      | asset2       |
      | asset3       |
    When I run `repo list --template=default.erb  --output=data/output.html --verbose`
    Then the exit status should be 0
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

  Scenario: Unsupported template file extension
    Given the folder "data/app_assets" with the following asset configurations:
      | name         |
      | asset1       |
      | asset2       |
      | asset3       |
    And a file named "template.fOO" with:
      """
      this file was not overwritten
      """
    When I run `repo list --template=template.fOO  --output=data/output.html --verbose`
    Then the exit status should be 1
    And the output should contain:
      """
      unsupported template type based on file extension .foo
      """

  Scenario: Default action, no filter, --list==SHORT
    Given a file named "repo.conf" with:
      """
      ---
      repos:
        test1:
          path: test_path_1
        test2:
          path: test_path_2
      """
    When I run `repo list --list=SHORT --verbose`
    Then the exit status should be 0
    And the output should contain:
      """
      test1: ./test_path_1
      test2: ./test_path_2
      """

  Scenario: Default action, no filter, --list=NAME
    Given a file named "repo.conf" with:
      """
      ---
      repos:
        test1:
          path: test_path_1
        test2:
          path: test_path_2
      """
    When I run `repo list --list=NAME`
    Then the exit status should be 0
    And the output should contain:
      """
      test1
      test2
      """

  Scenario: Default action, no filter, --list=PATH
    Given a file named "repo.conf" with:
      """
      ---
      repos:
        test1:
          path: test_path_1
        test2:
          path: test_path_2
      """
    When I run `repo list --list=PATH`
    Then the exit status should be 0
    And the output should match:
      """
      .+/test_path_1$
      .+/test_path_2$
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
    When I run `repo list --list=SHORT`
    Then the exit status should be 0
    And the output should contain:
      """
      test1: ./test1
      test2: ./test2
      """

  Scenario: Missing repos is still valid
    Given a file named "repo.conf" with:
      """
      ---
      repos:
      """
    When I run `repo list --list=SHORT`
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
    When I run `repo list --filter=test1 --list=SHORT --no-verbose`
    Then the exit status should be 0
    And the output should contain exactly:
      """
      test1: ./test1

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
    When I run `repo list test1 --list=SHORT --no-verbose`
    Then the output should contain exactly:
      """
      test1: ./test1

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
    And the output should contain:
      """
      test1:
      ---
      name: test1
      path: test1
      remotes:
        origin: ./remotes/test1.git

      test2:
      ---
      name: test2
      path: test2
      """
