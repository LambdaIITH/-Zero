package helpers

import "regexp"

// Contains checks if a value exists in a slice.
func Contains(slice []string, value string) bool {
	for _, item := range slice {
		if item == value {
			return true
		}
	}
	return false
}

// MatchRegex checks if a string matches a given regex pattern.
func MatchRegex(value string, pattern *regexp.Regexp) bool {
	return pattern.MatchString(value)
}
