import UIKit

final class MovieQuizViewController: UIViewController, QuestionFactoryDelegate {
    
    
    // MARK: - IBOutlet
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet private weak var textLabel: UILabel!
    @IBOutlet private weak var counterLabel: UILabel!
    @IBOutlet weak var noButton: UIButton!
    @IBOutlet weak var yesButton: UIButton!
    @IBOutlet private weak var activityIndicator: UIActivityIndicatorView!
    // MARK: - Private Properties
    
    private let button = UIButton()
    private let presenter = MovieQuizPresenter()
    private var statisticService: StatisticService?
    
   
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        presenter.viewController = self
        
        imageView.layer.cornerRadius = 20
        
        presenter.questionFactory = QuestionFactory(moviesLoader: MoviesLoader(), delegate: self)
        
        showLoadingIndicator()
        
        presenter.questionFactory?.loadData()
        
        presenter.questionFactory?.requestNextQuestion()
        
        presenter.alertPresenter = AlertPresenter(viewController: self)
        
        statisticService = StatisticServiceImplementation()
    
    }
    
    // MARK: - Private Methods

    func show(quiz step: QuizStepViewModel) {
        imageView.image = step.image
        textLabel.text = step.question
        counterLabel.text = step.questionNumber
    }
    
    
    func showAnswerResult(isCorrect: Bool) {
        presenter.didAnswer(isCorrectAnswer: isCorrect)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            guard let self = self else { return }
            self.presenter.showNextQuestionOrResults()
            self.presenter.questionFactory = self.presenter.questionFactory
            
            self.imageView.layer.borderColor = UIColor.ypBlack.cgColor
            self.noButton.isEnabled = true
            self.yesButton.isEnabled = true

        }
    }
    
    func showQuizResults() {
        if presenter.isLastQuestion() {
            
            if let statisticService = statisticService {
                statisticService.store(correct: presenter.correctAnswers, total: presenter.questionsAmount)
                
                let alertModel = AlertModel(title: "Этот раунд окончен!",
                                            message: resultMessage(),
                                            buttonText: "Сыграть ещё раз",
                                            completion: { [weak self] in
                    guard let self = self else {
                        return
                    }
                    self.presenter.resetQuestionIndex()
                    self.presenter.questionFactory?.requestNextQuestion()
                    
                }
                )
                presenter.alertPresenter?.show(alertModel: alertModel)
            }
        }
    }
    
        
        func resultMessage() -> String {
            guard let statisticService = statisticService, let bestGame = statisticService.bestGame else {
                assertionFailure("error message")
                return ""
            }
            
            let totalGamesCount = "Количество сыгранных квизов: \(statisticService.gamesCount)"
            let currentGameResult = "Ваш результат: \(presenter.correctAnswers)\\\(presenter.questionsAmount)"
            let bestGameInfo = "Рекорд: \(bestGame.correct)\\\(bestGame.total)" + " (\(bestGame.date.dateTimeString))"
            let averageAccuracy = "Средняя точность: \(String(format: "%.2f", statisticService.totalAccuracy))%"
            
            let resultMessage = [
                currentGameResult, totalGamesCount, bestGameInfo, averageAccuracy].joined(separator: "\n")
            
            return resultMessage
        }
        
    
    private func showLoadingIndicator() {
        activityIndicator.isHidden = false
        activityIndicator.startAnimating()
    }
    
    
    private func hideLoadingIndicator() {
        activityIndicator.isHidden = true
    }
    
    
    private func showNetworkError(message: String) {
        hideLoadingIndicator()
        
        let alertModel = AlertModel(title: "Ошибка",
                                    message: message,
                                    buttonText: "Попробовать еще раз",
                                    completion: { [weak self] in
            guard let self = self else {
                return
            }
            self.presenter.resetQuestionIndex()
            self.presenter.questionFactory?.requestNextQuestion()
        }
        )
        presenter.alertPresenter?.show(alertModel: alertModel)
    }
    
    
    // MARK: - QuestionFactoryDelegate
    
    func didReceiveNextQuestion(question: QuizQuestion?) {
        presenter.didReceiveNextQuestion(question: question)
    }
    
    
    func didLoadDataFromServer() {
        activityIndicator.isHidden = true
        presenter.questionFactory?.requestNextQuestion()

    }

    
    func didFailToLoadData(with error: Error) {
        showNetworkError(message: error.localizedDescription)
    }
    
    // MARK: - IBAction
    
    @IBAction private func noButtonClicked(_ sender: UIButton) {
        presenter.noButtonClicked(noButton)
    }

    @IBAction private func yesButtonClicked(_ sender: UIButton) {
        presenter.yesButtonClicked(yesButton)
    }
}

