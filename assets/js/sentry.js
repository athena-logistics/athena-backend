import {
  Replay,
  BrowserTracing,
  init as sentryInit,
  showReportDialog as sentryShowReportDialog,
} from "@sentry/browser";

function currentUrlWithoutParameters() {
  return location.pathname
    .replace(
      /[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}/gi,
      "<uuid>"
    )
    .replace(/\d{4}-\d{2}-\d{2}/g, "<date>");
}

export function init(dataset) {
  sentryInit({
    dsn: dataset.sentryDsn,
    integrations: [
      new BrowserTracing({
        beforeNavigate: (context) => ({
          ...context,
          name: currentUrlWithoutParameters(),
        }),
      }),
      new Replay(),
    ],
    tracesSampleRate: 1,
    replaysSessionSampleRate: 1,
    replaysOnErrorSampleRate: 1,
  });
  document.addEventListener(
    "DOMContentLoaded",
    () => {
      const element = document.getElementById("sentry-report");
      console.log(element);

      if (!element) return;

      sentryShowReportDialog({
        ...JSON.parse(element.dataset.reportOptions),
      });
    },
    false
  );
}
