# Papier
SwiftUI paper trader

# Architecture
Inspired by [Clean Architecture](https://nalexn.github.io/clean-architecture-swiftui/) but deviates quite a bit

## View

Just a standard SwiftUI view

## Interactor

Going back and forth calling this a view model or interactor. It's job is to interact with stores to make data accessible to views. 
**You should assume there can be more than one instance of an interactor connected to the same store**. Interactors are used for state
which will only exist while a view is presented, and state that should be separated between different instances of a view. Anything such
as caching which multiple interactors can benefit from should go in a store. A single interactor can also work with multiple stores if needed.

## Store

High level interface for working with a particular data type. You can assume these are long running instances, and will have multiple clients at a time.
You can also assume these will at times have 0 clients. This allows for state which is present for the entire app lifecycle. These are the gateway to working
with other services such as storage and networking. You should strive to keep their interfaces as small as possible. Make heavy use of caching to perform the
least amount of work possible

## Networking

### RequestFactory

Each API the app connects to should have a request factory, this is where most of the networking logic for that service should go. Factories should return a 
`Request<T>` object, which is a simple wrapper around `URLRequest` with a typed response. This should also be wrapped in `Result<Request<T>, RequestConstructionError>`
to encapsulate and test any failures. We use a Result instead of throwing to maintain typed errors.

### RequestServicer

A generic, small object whose sole job is perform `URLRequests`. Every API request should go through this object so that they can be scheduled and monitored appropriately.
This also keeps a very small surface that we have to mock. I have been toying with the idea of having a DecoratedRequestServicer for each service, where logic specific to that
service can be performed on pre/post request hooks, these would still ultimately still pass to a higher RequestServicer, I just haven't had a need yet.

### Environment

An object to hold objects basically. Currently has a global `shared` instance, individual objects aside from views should refrain from using it. The reason this is needed
instead of the SwiftUI environment, is that there are no `lazy` properties allowed in a `View`, so it wouldn't be possible to create an `Interactor` and inject objects
from the SwiftUI environment. So instead, the `Environment` is responsable for instantiating interactors using other objects it owns, primarily stores. I also do not
like that you can't inject an object via protocol into the SwiftUI environment, so it seems really difficult to mock dependencies.


## Why is it set up like this?

I wanted a clean separation of app/view state, and didn't want to go with a full redux-style-store as I feel it's less necessary in Swift compared to JavaScript.
The main things this misses out on are logging of every state update (but Stores can do this), and ability to rewind state while debugging, which is cool, but I
personally haven't missed.

Especially now with SwiftUI supporting so many platforms and the ability to have multiple scenes, I feel it's really important to assume you are going to have multiple
of the same view connected to the same datasource with some state unique to each instance.

Each of these layers should be easy to test, and easy to mock, I just haven't gotten around to writing the tests yet as there seemed to be a bug in Xcode 12 preventing
unit tests from building. 

