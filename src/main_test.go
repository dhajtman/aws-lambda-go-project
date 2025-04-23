package main

import (
	"testing"
)

// Sample XML from ENTSO-E data
var testXML = []byte(`
<GL_MarketDocument xmlns="urn:iec62325.351:tc57wg16:451-6:generationloaddocument:3:0">
    <TimeSeries>
        <Period>
            <Point>
                <position>1</position>
                <quantity>5929</quantity>
            </Point>
            <Point>
                <position>2</position>
                <quantity>6628</quantity>
            </Point>
        </Period>
    </TimeSeries>
</GL_MarketDocument>
`)

func TestExtractValuesFromXml(t *testing.T) {
	quantities, err := extractValuesFromXml(testXML, "quantity")
	if err != nil {
		t.Fatalf("Expected no error, got: %v", err)
	}

	expected := []string{"5929", "6628"}
	if len(quantities) != len(expected) {
		t.Fatalf("Expected %d values, got %d", len(expected), len(quantities))
	}

	for i, v := range expected {
		if quantities[i] != v {
			t.Errorf("At index %d, expected %s, got %s", i, v, quantities[i])
		}
	}
}

func TestExtractFromEmptyXml(t *testing.T) {
	values, err := extractValuesFromXml([]byte(""), "quantity")
	if len(values) != 0 && err != nil {
		t.Errorf("Expected 0 values, got %d", len(values))
	}
}

func TestExtractNonExistentTag(t *testing.T) {
	result, err := extractValuesFromXml(testXML, "nonexistent")
	if err != nil {
		t.Fatalf("Unexpected error: %v", err)
	}
	if len(result) != 0 {
		t.Errorf("Expected 0 values, got %d", len(result))
	}
}

func TestBuildCSVFromQuantitiesAndPositions(t *testing.T) {
	positions, _ := extractValuesFromXml(testXML, "position")
	quantities, _ := extractValuesFromXml(testXML, "quantity")

	if len(positions) != len(quantities) {
		t.Fatalf("Mismatched lengths: positions %d vs quantities %d", len(positions), len(quantities))
	}

	var rows [][]string
	rows = append(rows, []string{"position", "quantity"}) // header
	for i := range positions {
		rows = append(rows, []string{positions[i], quantities[i]})
	}

	if len(rows) != 3 {
		t.Errorf("Expected 3 rows (incl. header), got %d", len(rows))
	}

	if rows[1][0] != "1" || rows[1][1] != "5929" {
		t.Errorf("Unexpected data in first row: %v", rows[1])
	}
}
