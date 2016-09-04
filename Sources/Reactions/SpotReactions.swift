import Spots
import Brick
import Aftermath

// MARK: - Reload spots

public struct SpotReloadBuilder: ReactionBuilder {

  public let index: Int
  public weak var controller: AftermathController?

  public init(index: Int, controller: AftermathController) {
    self.index = index
    self.controller = controller
  }

  public func buildReaction() -> Reaction<[ViewModel]> {
    return Reaction(
      progress: {
        self.controller?.refreshControl.beginRefreshing()
      },
      done: { (viewModels: [ViewModel]) in
        self.controller?.spot(self.index, Spotable.self)?.reloadIfNeeded(viewModels)
      },
      fail: { error in
        self.controller?.errorHandler?(error: error)
      },
      complete: {
        self.controller?.refreshControl.endRefreshing()
      }
    )
  }
}

// MARK: - Insert view model

public enum Insert {
  case Append([ViewModel])
  case Prepend([ViewModel])
  case Index(Int, ViewModel)
}

public struct SpotInsertBuilder: ReactionBuilder {

  public let index: Int
  public weak var controller: AftermathController?

  public init(index: Int, controller: AftermathController) {
    self.index = index
    self.controller = controller
  }

  public func buildReaction() -> Reaction<Insert> {
    return Reaction(
      done: { (insert: Insert) in
        let spot = self.controller?.spot(self.index, Spotable.self)

        switch insert {
        case .Append(let viewModels):
          spot?.append(viewModels)
        case .Prepend(let viewModels):
          spot?.prepend(viewModels)
        case .Index(let index, let viewModel):
          spot?.insert(viewModel, index: index)
        }
      },
      fail: { error in
        self.controller?.errorHandler?(error: error)
      }
    )
  }
}

// MARK: - Update view model at index

public struct SpotUpdateBuilder: ReactionBuilder {

  public let index: Int
  public weak var controller: AftermathController?

  public init(index: Int, controller: AftermathController) {
    self.index = index
    self.controller = controller
  }

  public func buildReaction() -> Reaction<ViewModel> {
    return Reaction(
      done: { (viewModel: ViewModel) in
        guard let items = self.controller?.spot(self.index, Spotable.self)?.items,
          itemIndex = items.indexOf({ $0.identifier == viewModel.identifier })
          else { return }

        self.controller?.spot(self.index, Spotable.self)?.update(viewModel, index: itemIndex)
      },
      fail: { error in
        self.controller?.errorHandler?(error: error)
      }
    )
  }
}

// MARK: - Delete view model at index

public struct SpotDeleteBuilder: ReactionBuilder {

  public let index: Int
  public weak var controller: AftermathController?

  public init(index: Int, controller: AftermathController) {
    self.index = index
    self.controller = controller
  }

  public func buildReaction() -> Reaction<ViewModel> {
    return Reaction(
      done: { (viewModel: ViewModel) in
        guard let items = self.controller?.spot(self.index, Spotable.self)?.items,
          itemIndex = items.indexOf({ $0.identifier == viewModel.identifier })
          else { return }

        self.controller?.spot(self.index, Spotable.self)?.delete(itemIndex)
      },
      fail: { error in
        self.controller?.errorHandler?(error: error)
      }
    )
  }
}
