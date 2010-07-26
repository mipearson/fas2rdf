Feature: Convert FAS to RDF

  Scenario: Convert a valid FAS file to RDF
    Given I am on the home page
		And I attach the file "features/fixtures/valid.fas" to "convert_fas_file"
		When I press "Convert To RDF"
		Then I should receive a file matching the contents of "features/fixtures/valid.rdf"