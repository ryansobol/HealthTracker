enum AuthorizationError: Error {
	case authorizationRequestNecessary(metricType: MetricType)
	case sharingNotAuthorized(metricType: MetricType)
}
