import type { HealthCheckResponse } from "@repo/types";
import { formatMessage } from "@repo/utils";

const response: HealthCheckResponse = {
  status: "ok"
};

console.log(formatMessage(`frontend:${response.status}`));
