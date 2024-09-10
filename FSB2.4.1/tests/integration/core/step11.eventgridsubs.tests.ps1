Describe 'AZ Event Grid Subscriptions' {

    BeforeAll {

        Set-AzContext -Subscription $custMgmtSubscriptionId -tenant $tenantId -ErrorAction Stop | Out-Null
        $dateTime = (Get-Date).ToString()
        $keyword = "evgs-rb-osdiskencrypt"
    }

    Context 'Search if there is an event grid subscription that contains the keyword' {
        It 'Check if there is a subscription with the given name' {
            $becauseText = ' Checked at: ' + $($dateTime)
            $eventSub = search-eventGridSub -keyword $keyword
            $eventSub[0] | Should -BeIn "evgs-rb-osdiskencrypt" -Because $becauseText
          }
    }
}