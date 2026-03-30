# Solution Design Reference

Detailed decision trees for designing n8n workflow solutions from vague requirements.

---

## Decision Tree: From Brief to Architecture

```
User brief
  |
  v
[Extract: trigger, source, processing, output]
  |
  v
[Any part missing?]
  |-- Yes --> [Can infer from context?]
  |             |-- Yes --> Infer and proceed
  |             |-- No  --> Ask 1 question (max)
  |-- No  --> Proceed
  |
  v
[Search templates: search_templates({query: "<brief summary>"})]
  |
  v
[Template match >= 70%?]
  |-- Yes --> Deploy template, modify to fit
  |-- No  --> Build from scratch
  |
  v
[Select pattern(s)]
  |
  v
[Select nodes: search_nodes for each integration]
  |
  v
[Design flow: trigger -> process -> output -> error handler]
  |
  v
[Build]
```

---

## Common Business Scenarios -> Technical Solutions

### Scenario: Lead collection and qualification

**Brief**: "Zbieraj leady z formularza i kwalifikuj je"

**Solution**:
```
Webhook (form POST)
  -> Set (map form fields: name, email, company, message)
  -> AI Agent (OpenAI: qualify lead as hot/warm/cold based on message + company)
  -> Switch (by qualification)
     -> Hot  --> Slack (#sales-urgent) + Google Sheets (hot leads) + Email to sales rep
     -> Warm --> Google Sheets (warm leads) + Slack (#sales)
     -> Cold --> Google Sheets (all leads)
  -> Error Handler --> Slack (#ops-alerts)
```

**Key decisions**:
- AI for qualification (not rules) because natural language analysis
- Switch instead of IF because 3+ categories
- Google Sheets for storage (simple, client can access)
- Slack for notifications (real-time)

---

### Scenario: Content monitoring and alerts

**Brief**: "Monitoruj konkurencje i informuj mnie o zmianach"

**Solution**:
```
Schedule (every 6 hours)
  -> HTTP Request (fetch competitor pages / RSS feeds)
  -> Code (extract key content, compare with previous version)
  -> n8n Data Table (store current version for comparison)
  -> IF (content changed?)
     -> True  --> AI (summarize changes) -> Slack/Email (daily digest)
     -> False --> No action
  -> Error Handler --> Slack
```

**Key decisions**:
- Schedule (not webhook) because polling external sites
- Code node for content extraction (flexible, handles HTML)
- Data Table for storing previous versions (key-value cache)
- AI for summarization (human-readable digest)

---

### Scenario: Customer support automation

**Brief**: "Automatyzuj odpowiedzi na typowe pytania klientow"

**Solution**:
```
Webhook (from helpdesk / chat widget)
  -> AI Agent
     |-- Model: OpenAI/Anthropic (ai_languageModel)
     |-- Tools: HTTP Request Tool (search knowledge base) (ai_tool)
     |-- Memory: Window Buffer Memory (ai_memory)
  -> IF (confidence > 80%?)
     -> True  --> Webhook Response (send AI answer)
     -> False --> Create ticket in helpdesk + Slack (#support: needs human)
  -> Error Handler --> Webhook Response (generic "we'll get back to you")
```

**Key decisions**:
- AI Agent (not simple AI node) because needs tool access + memory
- Confidence threshold to escalate to human
- Webhook response for real-time reply
- Error handler returns safe response (never leave customer hanging)

---

### Scenario: Data sync between systems

**Brief**: "Synchronizuj kontakty miedzy CRM a Google Sheets"

**Solution**:
```
Schedule (every 15 minutes)
  -> CRM node (get recently updated contacts)
  -> IF (new records exist?)
     -> True  --> Google Sheets (lookup existing)
                  -> Code (diff: new vs. existing, find changes)
                  -> Split In Batches (process 50 at a time)
                     -> Google Sheets (upsert changed/new records)
                  -> Set (update sync timestamp)
     -> False --> No action
  -> Error Handler --> Slack + store failed records for retry
```

**Key decisions**:
- Schedule (not trigger) for reliability and rate limit control
- Batch processing to handle large datasets
- Upsert (not insert) to avoid duplicates
- Sync timestamp to only process changes since last run

---

### Scenario: Report generation

**Brief**: "Generuj tygodniowy raport z danych sprzedazowych"

**Solution**:
```
Schedule (Monday 8:00)
  -> Database/API (fetch sales data for last 7 days)
  -> Code (aggregate: totals, averages, top products, trends)
  -> AI (generate executive summary from aggregated data)
  -> Set (format HTML email template)
  -> Email (send to distribution list)
  -> Google Sheets (archive report data)
  -> Error Handler --> Slack (#ops: report generation failed)
```

**Key decisions**:
- Schedule on Monday morning (business context)
- Code node for aggregation (precise math, not AI)
- AI only for summary text (not calculations)
- Archive to Sheets (audit trail)

---

### Scenario: E-commerce order processing

**Brief**: "Przetwarzaj zamowienia ze sklepu"

**Solution**:
```
Webhook (from e-commerce platform: order.created)
  -> Set (extract: order_id, items, customer, total, shipping)
  -> IF (total > 500?)
     -> True  --> Flag for manual review + Slack (#high-value-orders)
     -> False --> Continue
  -> Google Sheets (order log)
  -> HTTP Request (update inventory system)
  -> Email (order confirmation to customer)
  -> Slack (#orders: new order summary)
  -> Error Handler --> Slack (#ops) + retry queue
```

**Key decisions**:
- Webhook (e-commerce platforms send webhooks on events)
- High-value order flagging (business rule)
- Multiple outputs in parallel where possible
- Inventory update as separate step (can fail independently)

---

### Scenario: Social media automation

**Brief**: "Postuj automatycznie na social media"

**Solution**:
```
Schedule (daily at 10:00 / MWF at 9:00)
  -> Google Sheets (get next scheduled post from content calendar)
  -> IF (post scheduled for today?)
     -> True  --> Set (format for each platform)
                  -> HTTP Request (post to Twitter/X API)
                  -> HTTP Request (post to LinkedIn API)
                  -> HTTP Request (post to Facebook API)
                  -> Google Sheets (mark as posted, add post URLs)
     -> False --> No action
  -> Error Handler --> Slack (#marketing: post failed for [platform])
```

**Key decisions**:
- Google Sheets as content calendar (client-friendly, easy to manage)
- Separate HTTP requests per platform (different APIs, different failures)
- Mark as posted to prevent duplicates
- Schedule instead of manual (true automation)

---

### Scenario: File processing pipeline

**Brief**: "Przetwarzaj pliki uploadowane przez klientow"

**Solution**:
```
Webhook (file upload notification) / Google Drive Trigger
  -> HTTP Request (download file)
  -> Switch (by file type: PDF, CSV, image)
     -> PDF  --> Code (extract text) -> AI (summarize/extract data)
     -> CSV  --> Code (parse, validate) -> Database (import rows)
     -> Image --> HTTP Request (OCR API) -> Set (extracted text)
  -> Merge (combine results)
  -> Google Sheets / Database (store processed results)
  -> Email / Slack (notify: "File processed successfully")
  -> Error Handler --> Slack + Email ("File processing failed: [filename]")
```

**Key decisions**:
- Switch by file type (different processing per type)
- External OCR for images (n8n doesn't have built-in)
- Merge to reunify branches
- Specific error message with filename

---

## Node Selection Cheat Sheet

### Communication / Notifications
| Need | Node | nodeType |
|------|------|----------|
| Slack message | Slack | n8n-nodes-base.slack |
| Email (send) | Gmail / Send Email | n8n-nodes-base.gmail |
| Email (receive) | Email Trigger (IMAP) | n8n-nodes-base.emailReadImap |
| SMS | Twilio | n8n-nodes-base.twilio |
| Discord | Discord | n8n-nodes-base.discord |
| Telegram | Telegram | n8n-nodes-base.telegram |

### Data Storage
| Need | Node | nodeType |
|------|------|----------|
| Spreadsheet | Google Sheets | n8n-nodes-base.googleSheets |
| SQL database | Postgres / MySQL | n8n-nodes-base.postgres |
| NoSQL | MongoDB | n8n-nodes-base.mongoDb |
| Key-value | n8n Data Table | n8n_manage_datatable |
| Files | Google Drive / S3 | n8n-nodes-base.googleDrive |

### AI / ML
| Need | Node | nodeType |
|------|------|----------|
| Text generation | OpenAI | @n8n/n8n-nodes-langchain.openAi |
| AI Agent (tools+memory) | AI Agent | @n8n/n8n-nodes-langchain.agent |
| Classification | OpenAI / Anthropic | Use with system prompt |
| Embeddings | OpenAI Embeddings | @n8n/n8n-nodes-langchain.embeddingsOpenAi |
| Vector search | Pinecone / Qdrant | @n8n/n8n-nodes-langchain.vectorStore* |

### Processing
| Need | Node | nodeType |
|------|------|----------|
| Transform fields | Set | n8n-nodes-base.set |
| Conditional | IF | n8n-nodes-base.if |
| Multi-condition | Switch | n8n-nodes-base.switch |
| Custom logic | Code | n8n-nodes-base.code |
| Merge branches | Merge | n8n-nodes-base.merge |
| Batch processing | Split In Batches | n8n-nodes-base.splitInBatches |
| Wait/delay | Wait | n8n-nodes-base.wait |
| HTTP call | HTTP Request | n8n-nodes-base.httpRequest |

### Triggers
| Need | Node | nodeType |
|------|------|----------|
| HTTP endpoint | Webhook | n8n-nodes-base.webhook |
| Form | n8n Form Trigger | n8n-nodes-base.formTrigger |
| Schedule | Schedule Trigger | n8n-nodes-base.scheduleTrigger |
| Manual | Manual Trigger | n8n-nodes-base.manualTrigger |
| Chat | Chat Trigger | @n8n/n8n-nodes-langchain.chatTrigger |

### Project Management / CRM
| Need | Node | nodeType |
|------|------|----------|
| Jira | Jira | n8n-nodes-base.jira |
| Asana | Asana | n8n-nodes-base.asana |
| Trello | Trello | n8n-nodes-base.trello |
| HubSpot | HubSpot | n8n-nodes-base.hubspot |
| Notion | Notion | n8n-nodes-base.notion |
| Airtable | Airtable | n8n-nodes-base.airtable |

---

## Complexity Estimation

Use this to decide how much error handling and testing to add:

| Complexity | Nodes | Error handling | Testing |
|-----------|-------|---------------|---------|
| Simple | 3-5 | Basic (retry + notify) | Single test |
| Medium | 6-10 | Per-branch error paths | 2-3 test cases |
| Complex | 11+ | Full error workflow + recovery | Multiple test cases + edge cases |

---

## Template Matching Strategy

Before building from scratch, always search templates:

```
1. search_templates({query: "<task description>"})
2. search_templates({searchMode: "by_nodes", nodeTypes: [<required nodes>]})
3. search_templates({searchMode: "by_task", task: "<pattern_type>"})
```

**When to use template:**
- Match >= 70% of requirements
- Saves significant build time
- Well-structured starting point

**When to build from scratch:**
- No good match
- Requirements are unique
- Template would need >50% modification

**Template deployment:**
```
n8n_deploy_template({
  templateId: <id>,
  name: "<custom name>",
  autoFix: true,
  autoUpgradeVersions: true
})
```
Then modify with `n8n_update_partial_workflow` to fit exact requirements.
