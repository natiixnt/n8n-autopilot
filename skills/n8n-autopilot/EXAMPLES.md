# Example Briefs -> Autonomous Solutions

Real-world examples of vague client briefs and how n8n-autopilot solves them.

---

## Example 1: Minimal brief

### Brief (from client):
> "Chce dostawac powiadomienia jak ktos wypelni formularz na stronie"

### Phase 1 - Understanding:
- **Trigger**: Webhook (form submission)
- **Source**: Form data via HTTP POST
- **Processing**: Map form fields
- **Output**: Notification (channel unspecified - default to Slack + Email)
- **Missing**: Which form fields? What notification channel?
- **Decision**: Don't ask - build for generic form fields, use both Slack and Email

### Phase 2 - Design:
```
Pattern: Webhook Processing
Nodes: Webhook -> Set -> Slack + Gmail
Error: Error Trigger -> Slack (#ops)
```

### Phase 3 - Build:
```javascript
// Step 1: Create
n8n_create_workflow({
  name: "Form Submission Notifications",
  nodes: [{
    id: "webhook-1",
    name: "Form Webhook",
    type: "n8n-nodes-base.webhook",
    typeVersion: 2,
    position: [250, 300],
    parameters: {
      path: "form-submit",
      httpMethod: "POST",
      responseMode: "onReceived",
      responseData: "allEntries"
    }
  }],
  connections: {}
})

// Step 2: Add Set node (transform)
n8n_update_partial_workflow({
  id: "<id>",
  intent: "Add field mapping for form data",
  operations: [{
    type: "addNode",
    node: {
      name: "Map Fields",
      type: "n8n-nodes-base.set",
      position: [450, 300],
      parameters: {
        assignments: {
          assignments: [
            {name: "name", value: "={{$json.body.name}}", type: "string"},
            {name: "email", value: "={{$json.body.email}}", type: "string"},
            {name: "message", value: "={{$json.body.message}}", type: "string"},
            {name: "submitted_at", value: "={{$now.toISO()}}", type: "string"}
          ]
        }
      }
    }
  }, {
    type: "addConnection",
    source: "Form Webhook",
    target: "Map Fields"
  }]
})

// Step 3: Add Slack notification
// Step 4: Add Email notification
// Step 5: Add error handler
// Step 6: Connect all
```

### Phase 4 - Validate:
```
n8n_validate_workflow({id: "<id>", options: {profile: "runtime"}})
-> Fix any errors
-> Re-validate
```

### Phase 5 - Deliver:
```
Workflow gotowy: Form Submission Notifications
ID: abc123
Status: Aktywny

Co robi:
Odbiera dane z formularza na stronie (webhook POST), formatuje je i wysyla
powiadomienie na Slacka (#notifications) oraz email na podany adres.

Jak dziala:
Webhook (POST /form-submit) -> Map Fields -> Slack + Email

Wymagane credentials:
- Slack (OAuth2 token)
- Gmail (OAuth2)

Webhook URL: https://your-n8n.com/webhook/form-submit
(Podaj ten URL w konfiguracji formularza na stronie)
```

---

## Example 2: Business process brief

### Brief (from client):
> "Mamy sklep online. Chcemy zeby jak klient zlozy zamowienie powyzej 1000zl,
> ktos z zespolu dostal alert i zeby zamowienie bylo automatycznie sprawdzone
> pod katem fraud"

### Phase 1 - Understanding:
- **Trigger**: Webhook (order.created from e-commerce)
- **Source**: Order data (items, total, customer info)
- **Processing**: Check amount > 1000, AI fraud analysis
- **Output**: Alert to team (Slack), fraud flag in system
- **Inferred**: Need to store results, need error handling for AI

### Phase 2 - Design:
```
Pattern: Webhook Processing + AI
Nodes:
  Webhook -> Set (extract order data)
    -> IF (total > 1000)
      -> True:
        -> AI (fraud check: analyze customer history, order pattern)
        -> Switch (fraud risk: high/medium/low)
          -> High   -> Slack (#fraud-alert, urgent) + Block order (HTTP)
          -> Medium -> Slack (#orders-review) + Flag for review
          -> Low    -> Continue normal processing
      -> False: -> Continue normal processing
    -> Google Sheets (order log - all orders)
    -> Error Handler -> Slack (#ops)
```

### Phase 3 - Build:
Iterative build: 8 nodes, ~6 update operations, validate after each major addition.

### Delivery:
```
Workflow gotowy: High-Value Order Fraud Check
ID: xyz789

Co robi:
Automatycznie sprawdza zamowienia powyzej 1000zl pod katem fraud.
Uzywam AI do analizy wzorcow zamowienia. Wysokie ryzyko -> blokada + alert.
Srednie -> review. Niskie -> przepuszcza. Wszystko logowane w Sheets.

Wymagane credentials:
- OpenAI API key (dla analizy fraud)
- Slack OAuth
- Google Sheets OAuth
- HTTP credentials (jesli potrzebne do API sklepu)
```

---

## Example 3: Extremely vague brief

### Brief:
> "Chce cos z AI zeby pomagalo zespolowi"

### Phase 1 - Understanding:
- Everything is vague. Need to ask ONE question:
- **Question**: "Co zespol robi najczesciej reczenie / co zajmuje im najwiecej czasu?"

### If user says: "Odpowiadanie na emaile od klientow"

### Phase 2 - Design:
```
Pattern: AI Agent Workflow
Solution: AI email assistant that drafts responses

Email Trigger (IMAP)
  -> AI Agent
     |-- Model: OpenAI GPT-4 (ai_languageModel)
     |-- Tools: HTTP Request (search knowledge base) (ai_tool)
     |-- Memory: Window Buffer Memory (ai_memory)
  -> IF (confidence > 85%?)
     -> True  --> Gmail (send draft reply) + Slack ("Draft created for: [subject]")
     -> False --> Slack (#support: "Need human for: [subject]")
  -> Error Handler --> Slack
```

---

## Example 4: Multi-system integration

### Brief:
> "Mamy dane w Google Sheets, CRM w HubSpot, komunikacja na Slacku.
> Chce zeby to wszystko ze soba gadalo"

### Phase 1 - Understanding:
- Too vague to build one workflow. Need to clarify USE CASE.
- **Question**: "Jaki konkretny proces chcesz zautomatyzowac? Np. nowy lead w Sheets -> HubSpot -> Slack?"

### If user says: "Tak, dokladnie. Jak handlowiec doda lead do Sheets, niech pojawi sie w HubSpot i na Slacku"

### Phase 2 - Design:
```
Pattern: Scheduled Task (poll Sheets) + API Integration

Schedule (every 5 min)
  -> Google Sheets (get rows where "synced" column is empty)
  -> IF (new rows exist?)
     -> True  --> Split In Batches (10 at a time)
        -> HubSpot (create/update contact)
        -> Slack (#sales: "New lead: [name] from [company]")
        -> Google Sheets (mark row as synced, add HubSpot ID)
     -> False --> No action
  -> Error Handler --> Slack (#ops) + mark row as "sync-error"
```

---

## Example 5: Scheduled reporting

### Brief:
> "Potrzebuje raport co tydzien"

### Phase 1 - Understanding:
- **Question**: "Raport z czego? Jakie dane i skad?"

### If user says: "Ze sprzedazy, mamy API do naszego systemu"

### Phase 2 - Design:
```
Pattern: Scheduled Tasks

Schedule (Monday 8:00)
  -> HTTP Request (GET sales data, last 7 days)
  -> Code (aggregate: total revenue, order count, avg order value,
           top 5 products, week-over-week change)
  -> AI (generate executive summary paragraph)
  -> Code (build HTML email template with charts/tables)
  -> Gmail (send to distribution list)
  -> Google Sheets (archive weekly data row)
  -> Error Handler --> Slack + fallback email (plain text version)
```

---

## Example 6: No-question build

### Brief:
> "Monitoring uptime naszych serwisow"

### Phase 1 - Understanding:
- Everything is clear enough. No questions needed.
- **Trigger**: Schedule (every 5 min)
- **Source**: HTTP requests to service endpoints
- **Processing**: Check status codes
- **Output**: Alert on downtime

### Phase 2 - Design:
```
Pattern: Scheduled Tasks

Schedule (every 5 minutes)
  -> Code (define endpoints to check: [{name, url, expectedStatus}])
  -> Split In Batches
     -> HTTP Request (GET each endpoint, continueOnFail: true)
     -> IF (status !== expected OR error)
        -> True (down)  --> n8n Data Table (log: service, status, timestamp)
                            -> IF (was it up last check?)
                               -> True  --> Slack (#ops: "SERVICE DOWN: [name]")
                                            + Email (oncall team)
                               -> False --> Skip (already alerted)
        -> False (up)   --> IF (was it down last check?)
                               -> True  --> Slack (#ops: "SERVICE RECOVERED: [name]")
                               -> False --> Skip (normal)
  -> n8n Data Table (update last-known status for each service)
```

**Key**: No questions needed. Built complete monitoring with smart alerting
(only alerts on state changes, not every check).

---

## Pattern: How to handle "I don't know what I need"

When the user is very vague:
1. Don't ask multiple questions
2. Ask ONE targeted question: "Co Twoj zespol robi najczesciej recznie?"
3. From that answer, you can design the whole solution
4. Build a simple v1 - user can iterate after seeing it work

**The goal is always: deliver something working, fast.**
User will tell you what to change after they see it in action.
