# ShareableTodosV2:

# Overview
We want to be able to share data from our app to others. We might want to share links, text, images, and files that represent something in our app. We'd want to do all of this in the app itself, without having to use another app to share. Using ShareLink and ShareSheet, we can achieve all of this. 

For all intents and purposes, this repo demonstrates two things:
1. a very simple list todos, where we can toggle their completion, description, add and delete
2. the ability to share your list of todos by sending a link to another user which when tapped, directly opens the app and alerts the user if they would like to accept the new todos.

Finally, this app is completely vanilla MVVM SwiftUI with zero dependencies.

# Step 1: Todos
This part is very straightforward, we build a simple view model that holds onto a list of todos. Now we just need to add the sharelink button.

# Step 2: Meet ShareLink
We can simply put our sharelink as a primary action toolbar item:
```swift
struct AppView: View { 
    @Observed var vm: AppViewModel
    
    var body: some View {
        NavigatonStack {
            List {
                ForEach(vm.todos) { todo in
                    ...
                }
            }
            .toolbar {
                ToolbarItemGroup(placement: .primaryAction) {
                    ShareLink(item: URL("https://www.google.com")!) // Magic.
                }
            }
        }
    }
}
```
In a single extremely simple to read line of code, we get an entire sheet that provides a ton of super magical features, we didn't have to life a finger.

However, there is a lot to be said here. There are many initializers for customizing appearence and behavior. We could give a custom message and subject, which are used for message and mail apps, or even a custom preview. There is quite a bit of discussion behind the different permutations and behaviors of these initializers. I highly reccommend watching [this video](https://www.youtube.com/watch?v=rM_2i5YobF4&list=LL&index=1&t=1304s) for more.

Besides appearence, we could give it different data: a string, a URL, an image, or any type that conforms to Transferable.

Transferable is a protocol that was released WWDC22 to replace the nightmare that is NSItemProvider. [Here's the conference video explaining the protocol](https://developer.apple.com/videos/play/wwdc2022/10062/). Both of these support Apples transport APIs, such as drag-and-drop and copy-paste-board.

There are many ways to conform to transferrable, but for the sake of this demo, we will stick to using URLs. 

Remember that we want to send a URL to others on iMessage, that contains our list of todos, and when tapped, opens our app and prompts if we'd like to loads them in. For starts, you probably want to know how you can even write a URL that directly opens the app. Let's do that now.

# Writing a URL to Directly Open Our App
To create a URL that directly opens the app, we'll use a URL Scheme. You'll have to do this in XCode as follows:
1. Click the app container on the leftmost file column
2. Click the app target
3. Click the info tab
4. Expand the URL Types
5. Fill in the data for a new URL Type

To fill in the data use an identifier i.e. `com.foobarInc.todosLink` and scheme i.e. `todosLink`. For simplicity of this demo, I will not go into details of how this works.

This means now that if we write a url starting with `todosLink://` and click that link, the device will know that routes to your app and will directly launch the app. 


# Building the URL to store Todos
We want to click that link and open the app and load in todos, but we need to somehow transfer the data. We can encode our list of todos into a string using Codable:
```swift
let data = try! JSONEncoder().encode(todos)
let JSON = String(data: data, encoding: .utf8)!
```
We will use force unwrapping throughout this process just too keep things simple.

Now we just need to build the URL. In order for the link to be work properly, and to possibly compose more data into the URL, it is advised to use the `URLComponents`:
```swift
let data = try! JSONEncoder().encode(todos)
let JSON = String(data: data, encoding: .utf8)!
var components = URLComponents()
components.scheme = "todosLink"
components.host = ""
components.queryItems = [
    URLQueryItem(name: "json", value: JSON)
]
let url = components.url!
```
And just like that, we have the URL! But there are some things to consider. You would never ever in production send URLs over a network like this. The URLQueryItems are automatically encoded using `RFC 3986`, but that doesn't mean this is safe. You will also get a very large URL. However for the sake of simplicity, we will leave it at that. Finally, if you do not write out a proper network URL then the link won't work properly, you will not be able to click it.

With that all said, we now need to be able to parse that URL back into some todos:

# Catching a URL to our App
There is one last step, which is putting a view modifier on our view that allows us to handle a URL sent to the app which is done with a single line of code:
```swift
struct AppView: View { 
    @Observed var vm: AppViewModel
    
    var body: some View {
        NavigatonStack {
            List {
                ForEach(vm.todos) { todo in
                    ...
                }
            }
            .toolbar {
                ToolbarItemGroup(placement: .primaryAction) {
                    ShareLink(item: URL("https://www.google.com")!)
                }
            }
            .onOpenURL(perform: vm.openURL) // One line of code!
        }
    }
}
```
We just need to implement the `openURL` method on our view model:
```swift
func openURL(_ url: URL) {
    let components = URLComponents(url: url, resolvingAgainstBaseURL: false)!
    let dataString = components.queryItems!.first!.value!
    let data = dataString.data(using: .utf8)!
    todos = try! JSONDecoder().decode([Todo].self, from: data)
}
```
And just by breaking the URL into its components, extracting the first value (we send a single value) we get our data. We parse it to our todos and we're done! Lots of force unwrapping but its just to cut to the chase. 

# Summary
We can handle URLs simply by doing the following:
1. add a URL Scheme to your app target
2. write the proper URL to route to your app and hold onto data
3. add a `ShareLink` (1 line of code) to our view 
4. add the `.onOpenURL`(1 line of code) to our view to handle the URL
