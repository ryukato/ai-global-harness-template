export type HealthCheckStatus = "ok" | "degraded";

export type HealthCheckResponse = {
  status: HealthCheckStatus;
};
