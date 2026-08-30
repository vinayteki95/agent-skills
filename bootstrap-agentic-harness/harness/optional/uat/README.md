# UAT — Product-Flow Tests

End-to-end proof of user journeys, complementing unit/integration tests.

| | Unit / integration | UAT |
|--|--------------------|-----|
| Proves | Module correctness | Real user journeys across the app |
| When | Every PR | Release / major flow change |

## Structure

```
uat/
├── README.md
├── flows/            # one file per journey (Playwright/Maestro/etc.)
└── scripts/run-uat.sh
```

## Running

```bash
./uat/scripts/run-uat.sh
```

Add a flow per user-visible journey; wire the runner into the `full` sensor tier
and CI. Full rules: [`../docs/DOC_MAINTENANCE.md`](../docs/DOC_MAINTENANCE.md).
