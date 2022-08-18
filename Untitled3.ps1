$bar = @"
{
  "uid": "",
  "subscriptions": [
    {
      "name": "Dashboards_AverageRunningTime"
    },
    {
      "name": "Dashboards_DailyTotalJobs"
    },
    {
      "name": "Dashboards_DailyAverageQueuedTime"
    },
    {
      "name": "Dashboards_DailyTotalRunningTime"
    },
    {
      "name": "Dashboards_FailuresByWorkspace"
    }
  ],
  "repositories": [
    {
      "name": "Dashboards"
    }
  ],
  "cleanupTasks": [
    {
      "name": "Delete_Dashboard_Reports",
      "category": "Utilities"
    },
    {
      "name": "Delete_Dashboard_Temp_Files",
      "category": "Utilities"
    }
  ],
  "topics": [
    {
      "name": "SAMPLE_TOPIC"
    }
  ],
  "schedules": [
    {
      "name": "DashboardStatisticsGathering",
      "category": "Dashboards"
    }
  ],
  "name": "FME_PROJECT_TEST",
  "description": "Test Project",
  "readme": "readme",
  "workspaces": [
    {
      "name": "austinApartments.fmw",
      "repositoryName": "Samples"
    },
    {
      "name": "austinDownload.fmw",
      "repositoryName": "Samples"
    },
    {
      "name": "earthquakesextrusion.fmw",
      "repositoryName": "Samples"
    }
  ],
  "version": "1.0.0",
  "fmeHubPublisherUid": ""
}
"@

$baz = $bar | ConvertFrom-Json
