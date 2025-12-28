from playwright.sync_api import sync_playwright, expect

def run(playwright):
    browser = playwright.chromium.launch(headless=True)
    context = browser.new_context()
    page = context.new_page()

    # 1. Visit Homepage to check link
    print("Navigating to Homepage...")
    page.goto("http://localhost:8080/index.html")
    expect(page.get_by_role("link", name="The Bartender")).to_be_visible()

    # 2. Click link to Bartender
    print("Clicking link to Bartender...")
    page.get_by_role("link", name="The Bartender").click()
    expect(page.get_by_role("heading", name="The Bartender")).to_be_visible()

    # 3. Visit Settings
    print("Navigating to Settings...")
    # Be more specific with locator
    page.locator(".settings-link a").click()
    expect(page.get_by_role("heading", name="Settings")).to_be_visible()

    # 4. Enter API Key
    print("Entering API Key...")
    page.get_by_placeholder("Enter your API Key").fill("dummy-api-key-123")
    page.get_by_role("button", name="Save Settings").click()

    # Wait for success message
    expect(page.get_by_text("API Key saved successfully!")).to_be_visible()

    # 5. Navigate back to Bartender
    print("Navigating back to Bartender...")
    page.get_by_role("link", name="Back to Bartender").click()
    expect(page.get_by_role("heading", name="The Bartender")).to_be_visible()

    # 6. Verify initial state
    expect(page.get_by_text("Hello! I'm your digital bartender.")).to_be_visible()

    # 7. Send a message
    print("Sending message...")
    page.get_by_placeholder("e.g. I have whiskey and lemon").fill("I want a whiskey sour")
    page.get_by_role("button", name="Send").click()

    # 8. Verify user message appears
    expect(page.get_by_text("I want a whiskey sour")).to_be_visible()

    # 9. Verify bot attempts to respond
    try:
        expect(page.locator(".spinner")).to_be_visible(timeout=5000)
        print("Spinner visible")
    except:
        print("Spinner not caught (might be too fast or slow)")

    # Wait a bit for the mock/real API call to likely fail
    page.wait_for_timeout(3000)

    # Take screenshot of the chat
    page.screenshot(path="verification/bartender_chat_v2.png")

    browser.close()

with sync_playwright() as playwright:
    run(playwright)
