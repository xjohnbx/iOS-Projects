//
//  holeViewController.swift
//  golfApp
//
//Name/Author: John Brechon

// This viewController deals with all the calculations for each hole

import UIKit
import CoreData

class holeViewController: UIViewController {

//course hole and flags
    var courseChoiceHole = 0

//User Values
    var fairwayHit = false
    var GIRHit = false
    var holeNumberCounter = 1

    var course: Course?
    var coreRound:Round?
    var fetchedHoles:[Hole]?
    
//Outlets for on screen info
    @IBOutlet weak var holeScoreTextField: UITextField!
    @IBOutlet weak var holePuttsTextField: UITextField!
    @IBOutlet weak var holeGIRYesButton: UIButton!
    @IBOutlet weak var holeGIRNoButton: UIButton!
    @IBOutlet weak var holeFairwayYesButton: UIButton!
    @IBOutlet weak var holeFairwayNoButton: UIButton!
    @IBOutlet weak var holeNumber: UILabel!
    @IBOutlet weak var holePar: UILabel!
    @IBOutlet weak var holeYards: UILabel!
    @IBOutlet weak var userScoreToParLabel: UILabel!
    @IBOutlet weak var previousButton: UIButton!
    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var viewSummary: UIButton!
    @IBOutlet weak var cancelRound: UIButton!
    @IBOutlet weak var saveRound: UIButton!
    @IBOutlet weak var scorePlus: UIButton!
    @IBOutlet weak var puttsPlus: UIButton!
    @IBOutlet weak var scoreMinus: UIButton!
    @IBOutlet weak var puttsMinus: UIButton!
    @IBOutlet weak var navigationBar: UINavigationItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        readCourse()
        setupUI()
        createRound()
        self.navigationController?.navigationBar.isHidden = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.navigationBar.isHidden = true
    }

    func setupUI() {
        
        holeGIRNoButton.applyFormat()
        holeGIRYesButton.applyFormat()
        holeFairwayNoButton.applyFormat()
        holeFairwayYesButton.applyFormat()
        cancelRound.applyFormat()
        viewSummary.applyFormat()
        saveRound.applyFormat()
        scorePlus.applyFormat()
        scoreMinus.applyFormat()
        puttsPlus.applyFormat()
        puttsMinus.applyFormat()
 
        previousButton.isHidden = true
        previousButton.isEnabled = false
        
		guard course != nil else {
			print("Course has failed to read")
			return
		}
            //initialize hole1 values
        navigationItem.title = course?.name
        holeNumber.text = "\(holeNumberCounter)"
        holePar.text = "\(course!.holes[0].par)"
        holeYards.text = "\(course!.holes[0].yards)"
        userScoreToParLabel.text = "E"
        changeGIRNo()
        changeFairwayNo()
    }
        //This function will call the next hole after error checking
    @IBAction func nextHoleButton(_ sender: Any) {
        
        nextButton(hole: holeNumberCounter)
        
        if(errorCheck())
        {
            performHoleSave()
            holeNumberCounter += 1
            setupHole(holeCounter: holeNumberCounter)
        }
    }
    
        //This takes you to the previous hole
    @IBAction func prevHoleButton(_ sender: Any) {
        
        holeNumberCounter -= 1
        
        setupHole(holeCounter: holeNumberCounter)
        
        let index = holeNumberCounter - 1
        fairwayHit = coreRound!.holeArray![index].fairwayHit
        GIRHit = coreRound!.holeArray![index].girHit
    }
   
        //Error checking
    func errorCheck() -> Bool
    {
        var ok = true
        var alert = UIAlertController(title: "Error!", message: "Basic Error.", preferredStyle: .alert)
        
        if Int(holeScoreTextField.text!)! == 0 {
            alert = UIAlertController(title: "Error!", message: "Score cannot be 0.", preferredStyle: .alert)
            ok = false
            
            alert.addAction(UIAlertAction(title: "Dismiss", style: .cancel, handler: nil))
            self.present(alert,animated: true)
        }
            
        else if((holeScoreTextField.text! as NSString).integerValue <= (holePuttsTextField.text! as NSString).integerValue) {
                alert = UIAlertController(title: "Error!", message: "Putts must be less than Score.", preferredStyle: .alert)
                ok = false
            
            alert.addAction(UIAlertAction(title: "Dismiss", style: .cancel, handler: nil))
            
            self.present(alert, animated: true)
        }
        
        return ok
    }
    
//SetUp next Hole: increment hole number and setUp Next hole#, par, and yards
    
    func setupHole(holeCounter: Int)
    {
        
        prevButton(hole: holeCounter)
        nextButton(hole: holeCounter)
        let index = holeCounter - 1
        
    //Changing fields
        userScoreToParLabel.text = coreRound!.scoreToPar.toParText(scoreToPar: Int(coreRound!.scoreToPar))
        holeScoreTextField.text = "0"
        holePuttsTextField.text = "0"
        
        fairwayHit = false
        changeFairwayNo()
        
        GIRHit = false
        changeGIRNo()

        holeNumber.text = "\(holeCounter)"

    //non changing fields
        holePar.text = "\(course!.holes[index].par)"
        holeYards.text = "\(course!.holes[index].yards)"
        
        if coreRound!.holes!.count >= holeCounter {
            holeScoreTextField.text = "\(coreRound!.holeArray![index].strokes)"
            holePuttsTextField.text = "\(coreRound!.holeArray![index].putts)"
            coreRound!.holeArray![index].fairwayHit ? changeFairwayYes() : changeFairwayNo()
            coreRound!.holeArray![index].girHit ? changeGIRYes() : changeGIRNo()
        }
    }
    
    func changeGIRYes()
    {
        self.holeGIRYesButton.backgroundColor = UIColor.green
        self.holeGIRYesButton.setTitleColor(.black, for: .normal)
        self.holeGIRNoButton.backgroundColor = UIColor.clear
        self.holeGIRNoButton.setTitleColor(.black, for: .normal)
    }
    
    func changeGIRNo()
    {
        self.holeGIRNoButton.backgroundColor = UIColor.red
        self.holeGIRNoButton.setTitleColor(.black, for: .normal)
        self.holeGIRYesButton.backgroundColor = UIColor.clear
        self.holeGIRYesButton.setTitleColor(.black, for: .normal)
    }
    
    func changeFairwayYes()
    {
        self.holeFairwayYesButton.backgroundColor = UIColor.green
        self.holeFairwayYesButton.setTitleColor(.black, for: .normal)
        self.holeFairwayNoButton.backgroundColor = UIColor.clear
        self.holeFairwayNoButton.setTitleColor(.black, for: .normal)
    }
    
    func changeFairwayNo()
    {
        self.holeFairwayNoButton.backgroundColor = UIColor.red
        self.holeFairwayNoButton.setTitleColor(.black, for: .normal)
        self.holeFairwayYesButton.backgroundColor = UIColor.clear
        self.holeFairwayYesButton.setTitleColor(.black, for: .normal)
    }
    
    @IBAction func GIRYes(_ sender: Any) {
        GIRHit = true
        changeGIRYes()
    }
    
    @IBAction func GIRNo(_ sender: Any) {
        GIRHit = false
        changeGIRNo()
    }

    
    @IBAction func fairwayYes(_ sender: Any) {
        fairwayHit = true
        changeFairwayYes()
    }
    
    @IBAction func fairwayNo(_ sender: Any) {
        fairwayHit = false
        changeFairwayNo()
    }
    
    func prevButton(hole: Int) {
        if hole == 1 {
            previousButton.isHidden = true
            previousButton.isEnabled = false
        }
        else {
            previousButton.isHidden = false
            previousButton.isEnabled = true
        }
    }
    
    func nextButton(hole: Int) {
        if hole == 18 {
            nextButton.isHidden = true
            nextButton.isEnabled = false
        }
        else {
            nextButton.isHidden = false
            nextButton.isEnabled = true
        }
    }
        //can use some kind of parameter to choose between courses in the list then use if statements for what plist gets read.
	func readCourse() {
        
        var path = Bundle.main.url(forResource: "kish", withExtension: "json")!
        switch courseChoiceHole {
            case 1:
                path = Bundle.main.url(forResource: "sycamore", withExtension: "json")!
            case 2:
                path = Bundle.main.url(forResource: "kish", withExtension: "json")!
            case 3:
                path = Bundle.main.url(forResource: "emerald", withExtension: "json")!
            default:
                break
         }
		
		do {
			let data = try Data(contentsOf: path)
			parse(json: data)
		} catch {
			print(error)
		}
    }
	
	func parse(json: Data) {
		let decoder = JSONDecoder()
		
		do {
			course = try decoder.decode(Course.self, from: json)
		} catch {
			print(error)
		}
	}
	
    @IBAction func cancelRound(_ sender: Any) {
        
        let cancelRoundAlert = UIAlertController(title: "Cancel Round", message: "You are about to cancel the round. You will lose this rounds data. Are you sure you want to cancel?", preferredStyle: .alert)
        
        cancelRoundAlert.addAction(UIAlertAction(title: "Yes", style: .destructive, handler: { action in
            self.deleteRound()
            self.backToHomeViewController()
        }))
        
        cancelRoundAlert.addAction(UIAlertAction(title: "No", style: .cancel, handler: nil))
        self.present(cancelRoundAlert, animated: true)
    }
    
    @IBAction func saveRound(_ sender: Any) {
    
        let saveRoundHoleAlert = UIAlertController(title: "Save Round", message: "You are about to save the round. This prevents any more changes. Are you sure you want to save?", preferredStyle: .alert)
        if errorCheck() {
            saveRoundHoleAlert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { action in
                self.performHoleSave()
                do {
                    try self.coreRound?.managedObjectContext?.save()
                } catch {
                    print("Round was not saved")
                }
                self.backToHomeViewController()
            }))
            saveRoundHoleAlert.addAction(UIAlertAction(title: "No", style: .cancel, handler: nil))
            self.present(saveRoundHoleAlert, animated: true)
        }
    }
    
    func backToHomeViewController() {
        let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let navigationController = storyBoard.instantiateViewController(withIdentifier: "homeNav") as! UINavigationController
        
        self.present(navigationController, animated: true, completion: nil)
    }
    
    @IBAction func addScoreButton(_ sender: Any) {
        holeScoreTextField.text = "\(Int(holeScoreTextField.text!)! + 1)"
    }
    
    @IBAction func minusScoreButton(_ sender: Any) {
        if Int(holeScoreTextField.text!)! > 0 {
            holeScoreTextField.text = "\(Int(holeScoreTextField.text!)! - 1)"
        }
    }
    
    @IBAction func addPuttButton(_ sender: Any) {
        holePuttsTextField.text = "\(Int(holePuttsTextField.text!)! + 1)"
    }
    
    @IBAction func minusPuttButton(_ sender: Any) {
        if Int(holePuttsTextField.text!)! > 0 {
            holePuttsTextField.text = "\(Int(holePuttsTextField.text!)! - 1)"
        }
    }
    
    func performHoleSave() {

        let scoreToPar = Int(holeScoreTextField.text!)! - course!.holes[holeNumberCounter - 1].par
        coreRound!.holeArray!.count < holeNumberCounter ? createNewHole(holeNumber: holeNumberCounter, putts: Int(holePuttsTextField.text!)!, strokes: Int(holeScoreTextField.text!)!, fairway: fairwayHit, gir: GIRHit, scoreToPar: scoreToPar) : editRoundValues(strokes: Int(holeScoreTextField.text!)!, putts: Int(holePuttsTextField.text!)!, gir: GIRHit, fairway: fairwayHit, scoreToPar: scoreToPar)
    }
    
    func createNewHole(holeNumber: Int, putts: Int, strokes: Int, fairway: Bool, gir: Bool, scoreToPar: Int) {
        let hole = Hole(holeNumber: Int16(holeNumber), putts: Int16(putts), strokes: Int16(strokes), fairwayHit: fairway, girHit: gir)
        coreRound!.addToHoles(hole)
        
        do {
            try hole.managedObjectContext?.save()
        } catch {
            print("Hole was not saved")
        }
        
        coreRound!.totalScore += Int16(strokes)
        coreRound!.totalPutts += Int16(putts)
        coreRound!.scoreToPar += Int16(scoreToPar)
        
        if gir {
            coreRound?.totalGIRs += 1
        }
        if fairway {
            coreRound?.totalFairways += 1
        }
    }
    
    func createRound()
    {
        coreRound = Round(courseName: (course?.name)!, date: Date(), scoreToPar: 0, totalFairways: 0, totalGIRs: 0, totalPutts: 0, totalScore: 0)
        
        do {
            try coreRound?.managedObjectContext?.save()
            
        } catch {
            print("Could not save round.")
        }
    }
    
    func editRoundValues(strokes: Int, putts: Int, gir: Bool, fairway: Bool, scoreToPar: Int) {
        
        let index = holeNumberCounter - 1
        let oldScoreToPar = coreRound!.holeArray![index].strokes - Int16(course!.holes[index].par)
        
        if coreRound!.holeArray![index].girHit {
            coreRound!.totalGIRs -= 1
        }
        if coreRound!.holeArray![index].fairwayHit {
            coreRound!.totalFairways -= 1
        }
        
        coreRound!.totalScore = coreRound!.totalScore - coreRound!.holeArray![index].strokes + Int16(strokes)
        coreRound!.totalPutts = coreRound!.totalPutts - coreRound!.holeArray![index].putts + Int16(putts)
        coreRound!.scoreToPar = coreRound!.scoreToPar - oldScoreToPar + Int16(scoreToPar)
        
        coreRound!.holeArray![index].strokes = Int16(strokes)
        coreRound!.holeArray![index].putts = Int16(putts)
        coreRound!.holeArray![index].fairwayHit = fairway
        coreRound!.holeArray![index].girHit  = gir
        
        if gir {
            coreRound!.totalGIRs += 1
        }
        if fairway {
            coreRound!.totalFairways += 1
        }
    }
    
    func deleteRound() {
        guard let managedContext = coreRound?.managedObjectContext else {
            return
        }
        
        managedContext.delete(coreRound!)
        
        do {
            try managedContext.save()
        } catch {
            print("Round not deleted.")
        }
    }
    
        //This prepares for round summary
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if(segue.identifier == "endRound") {
            let endVC = segue.destination as! endRoundViewController
            endVC.endRound = coreRound
        }
    }
}
