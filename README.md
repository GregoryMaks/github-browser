# GitHub Browser

## Initial task description

github.com has public API to get list of users: "https://api.github.com/users". There are helpfull parameters like "per_page" and "since", check them.
You need to create iOS application, which allows to get list of github users loaded into table. Each row contains login, profile link (html_url) and avatar preview(100x100).
Tap on user should result in opening list of his followers.

We expect application will allow to browse at least first 100 users.
Using Swift is required.
Time limit: up to you.

Source code should be available on github.com.

## Solution details

**Architecture:** MVVM-C

**Language:** Swift

**Frameworks:**
<ul>
    <li>Swinject - DI for swift</li>
    <li>RxSwift - reactive extensions for swift</li>
    <li>Alamofire - networking library</li>
</ul>

**Testing:** none (as no testing was required)

## Main solution components

```UserListViewController``` - serves as main VC that user sees, works both for global user list and for the list of followers

```UserListCoordinator``` - coordinates all logic in switching between history of user views, contains only two recent UserListVCs (current and previous ones) to conserve memory

## Solution limitations

<ul>
    <li>No offline mode present</li>
    <li>Network errors are consumed and not displayed to the user (was not required to process)</li>
    <li>When going back in history of user views, scroll position and data may not be preserver (but loaded from network again)</li>
</ul>
