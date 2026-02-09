#!/bin/bash
set -e

# Main workflow orchestration script
# This script orchestrates the entire Claude code generation workflow

JOB_ID="$1"
ISSUE_ID="$2"
SERVICE_URL="$3"
BRANCH="$4"
GITHUB_REPOSITORY="$5"
GITHUB_RUN_ID="$6"
WORKFLOW_URL="$7"
API_KEY="$8"

SCRIPTS_DIR="$SIMPLE_FORGE_WORK_DIR/scripts"

echo "=========================================="
echo "🚀 Starting Simple Forge Workflow"
echo "=========================================="
echo "Job ID: $JOB_ID"
echo "Issue ID: $ISSUE_ID"
echo "Service URL: $SERVICE_URL"
echo "Branch: $BRANCH"
echo "Repository: $GITHUB_REPOSITORY"
echo "Run ID: $GITHUB_RUN_ID"
echo "Workflow URL: $WORKFLOW_URL"
echo "API Key: $([ -n "$API_KEY" ] && echo "[SET - ${#API_KEY} chars]" || echo "[EMPTY]")"
echo "=========================================="

# Function to handle errors
handle_error() {
    local step="$1"
    local exit_code="$2"
    echo "❌ Error in step: $step (exit code: $exit_code)"

    # Try to report failure to service
    if [ -f "$SCRIPTS_DIR/report-workflow-failure.sh" ]; then
        "$SCRIPTS_DIR/report-workflow-failure.sh" \
            "$JOB_ID" \
            "$SERVICE_URL" \
            "$API_KEY" \
            "$GITHUB_RUN_ID" \
            "$WORKFLOW_URL" \
            "$step" \
            "failure" \
            "failure" \
            "failure" || true
    fi

    exit "$exit_code"
}

# Step 0: Validate GitHub token
echo ""
echo "🔍 Step 0: Validating GitHub token..."
if ! "$SCRIPTS_DIR/validate-github-token.sh" "$GITHUB_REPOSITORY"; then
    handle_error "validate-github-token" $?
fi
echo "✅ Token validation complete"

# Step 1: Setup branch
echo ""
echo "📌 Step 1: Setting up branch..."
if ! "$SCRIPTS_DIR/setup-branch.sh" "$BRANCH"; then
    handle_error "setup-branch" $?
fi
echo "✅ Branch setup complete"

# Step 2: Initialize workflow tracking
echo ""
echo "📊 Step 2: Initializing workflow tracking..."
if ! "$SCRIPTS_DIR/initialize-workflow-tracking.sh" \
    "$JOB_ID" \
    "$SERVICE_URL" \
    "$GITHUB_RUN_ID" \
    "$WORKFLOW_URL" \
    "$API_KEY"; then
    handle_error "initialize-workflow-tracking" $?
fi
echo "✅ Workflow tracking initialized"

# Step 3: Fetch context from service
echo ""
echo "📥 Step 3: Fetching context from service..."
if ! "$SCRIPTS_DIR/fetch-context.sh" \
    "$JOB_ID" \
    "$SERVICE_URL" \
    "$API_KEY"; then
    handle_error "fetch-context" $?
fi
echo "✅ Context fetched"

# Step 4: Setup Claude Code
echo ""
echo "🤖 Step 4: Setting up Claude Code..."
if ! "$SCRIPTS_DIR/setup-claude.sh"; then
    handle_error "setup-claude" $?
fi
echo "✅ Claude Code setup complete"

# Step 5: Setup Claude plugins
echo ""
echo "🔌 Step 5: Setting up Claude Code plugins..."
if ! "$SCRIPTS_DIR/setup-claude-plugins.sh"; then
    handle_error "setup-claude-plugins" $?
fi
echo "✅ Claude plugins setup complete"

# Step 6: Prepare Claude conversation
echo ""
echo "💬 Step 6: Preparing Claude conversation..."
if ! "$SCRIPTS_DIR/prepare-claude-conversation.sh" \
    "$ISSUE_ID" \
    "$GITHUB_REPOSITORY"; then
    handle_error "prepare-claude-conversation" $?
fi
echo "✅ Conversation prepared"

# Step 7: Run Claude with context
echo ""
echo "🧠 Step 7: Running Claude with context..."
if ! "$SCRIPTS_DIR/run-claude-with-context.sh" \
    "$GITHUB_REPOSITORY" \
    "$BRANCH" \
    "$ISSUE_ID"; then
    handle_error "run-claude-with-context" $?
fi
echo "✅ Claude execution complete"

# Step 8: Process Claude response
echo ""
echo "⚙️  Step 8: Processing Claude response..."
if ! "$SCRIPTS_DIR/process-claude-response.sh" \
    "$ISSUE_ID" \
    "$BRANCH" \
    "$GITHUB_RUN_ID" \
    "$WORKFLOW_URL"; then
    handle_error "process-claude-response" $?
fi
echo "✅ Response processed"

# Step 9: Commit and push changes
echo ""
echo "💾 Step 9: Committing and pushing changes..."
if ! "$SCRIPTS_DIR/commit-and-push.sh" \
    "$ISSUE_ID" \
    "$JOB_ID" \
    "$BRANCH" \
    "$WORKFLOW_URL"; then
    handle_error "commit-and-push" $?
fi
echo "✅ Changes committed and pushed"

# Step 10: Upload handoff file (if present)
echo ""
echo "📤 Step 10: Uploading handoff file (if present)..."
if [ -f "$SCRIPTS_DIR/upload-handoff-file.sh" ]; then
    if ! "$SCRIPTS_DIR/upload-handoff-file.sh" \
        "$JOB_ID" \
        "$SERVICE_URL" \
        "$API_KEY"; then
        echo "⚠️  Warning: Failed to upload handoff file"
    fi
else
    echo "⚠️  Warning: upload-handoff-file.sh not found, skipping handoff upload"
fi
echo "✅ Handoff upload step complete"

# Step 11: Update context back to service
echo ""
echo "📤 Step 11: Updating context to service..."
if ! "$SCRIPTS_DIR/update-context.sh" \
    "$JOB_ID" \
    "$SERVICE_URL" \
    "$BRANCH" \
    "$API_KEY"; then
    handle_error "update-context" $?
fi
echo "✅ Context updated"

# Step 12: Job completion summary
echo ""
echo "📋 Step 12: Generating job completion summary..."
if ! "$SCRIPTS_DIR/job-completion-summary.sh" \
    "$JOB_ID" \
    "$ISSUE_ID" \
    "$BRANCH" \
    "success" \
    "$WORKFLOW_URL"; then
    echo "⚠️  Warning: Failed to generate completion summary"
fi

echo ""
echo "=========================================="
echo "✅ Workflow completed successfully!"
echo "=========================================="
echo "status=success" >> $GITHUB_OUTPUT
echo "workflow_url=$WORKFLOW_URL" >> $GITHUB_OUTPUT
