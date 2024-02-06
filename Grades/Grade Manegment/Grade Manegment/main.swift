import Foundation
import CSV

// Global variable to store student names
var students: [String] = []

// Function to load grades from CSV file
func loadGradesFromCSV() -> [[Double]] {
    do {
        let stream = InputStream(fileAtPath: "/Users/studentam/desktop/grades.csv")
        let csv = try CSVReader(stream: stream!)

        var grades: [[Double]] = []

        // Iterate through each row in the CSV
        while let row = csv.next() {
            // The first row contains student names
            if students.isEmpty {
                students = row
            } else {
                // Convert string values to double and append to grades array
                let rowGrades = row.compactMap { Double($0) }
                grades.append(rowGrades)
            }
        }
        return grades
    } catch {
        print("Error loading CSV file: \(error)")
        return []
    }
}

// Function to display the menu
func displayMenu() {
    print("\nWelcome to the Grade Manager!")
    print("1. Display grade of a single student")
    print("2. Display all grades for a student")
    print("3. Display all grades of ALL students")
    print("4. Find the average grade of the class")
    print("5. Find the average grade of an assignment")
    print("6. Find the lowest grade in the class")
    print("7. Find the highest grade of the class")
    print("8. Filter students by grade range")
    print("9. Quit")
}

// Function to get user input
func getUserInput() -> String {
    print("\nWhat would you like to do? (Enter the number):", terminator: "")
    if let input = readLine() {
        return input
    }
    return ""
}

// Main function
func main() {
    // Load grades from CSV file
    let grades: [[Double]] = loadGradesFromCSV()
    
    // Display menu and handle user input
    var userInput = ""
    repeat {
        displayMenu()
        userInput = getUserInput()

        switch userInput {
        case "1":
            displaySingleStudentGrade(grades: grades)
        case "2":
            displayAllGradesForStudent(grades: grades)
        case "3":
            displayAllGradesForAllStudents(grades: grades)
        case "4":
            findAverageGradeOfClass(grades: grades)
        case "5":
            findAverageGradeOfAssignment(grades: grades)
        case "6":
            let lowestGrade = findLowestGrade(grades: grades)
            print("\n\(students[grades.firstIndex(where: { $0.contains(lowestGrade) }) ?? 0]) is the student with the lowest grade: \(lowestGrade)")
        case "7":
            let highestGrade = findHighestGrade(grades: grades)
            print("\n\(students[grades.firstIndex(where: { $0.contains(highestGrade) }) ?? 0]) is the student with the highest grade: \(highestGrade)")
        case "8":
            print("\nEnter the low range you would like to use:")
            if let lowRangeStr = readLine(), let lowRange = Double(lowRangeStr) {
                print("\nEnter the high range you would like to use:")
                if let highRangeStr = readLine(), let highRange = Double(highRangeStr) {
                    filterStudentsByGradeRange(grades: grades, low: lowRange, high: highRange)
                } else {
                    print("\nInvalid input. Please enter a valid high range.")
                }
            } else {
                print("\nInvalid input. Please enter a valid low range.")
            }
        case "9":
            print("\nHave a great rest of your day!")
        default:
            print("\nInvalid option. Please enter a valid number.")
        }
    } while userInput != "9"
}

// Call the main function to start the program
main()


// Function to calculate the average of an array of grades
func calculateAverage(grades: [Double]) -> Double {
    let sum = grades.reduce(0, +)
    return sum / Double(grades.count)
}

// Function to find the lowest grade in the class
func findLowestGrade(grades: [[Double]]) -> Double {
    let allGrades = grades.flatMap { $0 }
    return allGrades.min() ?? 0
}

// Function to find the highest grade in the class
func findHighestGrade(grades: [[Double]]) -> Double {
    let allGrades = grades.flatMap { $0 }
    return allGrades.max() ?? 0
}

// Function to filter students by grade range
func filterStudentsByGradeRange(grades: [[Double]], low: Double, high: Double) {
    for (index, studentGrades) in grades.enumerated() {
        let average = calculateAverage(grades: studentGrades)
        if average >= low && average <= high {
            print("\(index + 1). \(students[index]): \(average)")
        }
    }
}

// Function to display grades of a single student
func displaySingleStudentGrade(grades: [[Double]]) {
    print("\nWhich student would you like to choose?")
    if let studentName = readLine()?.lowercased() {
        if let index = students.firstIndex(where: { $0.lowercased() == studentName }) {
            let average = calculateAverage(grades: grades[index])
            print("\n\(students[index])'s grade in the class is \(average)")
        } else {
            print("\nStudent does not exist. Please enter a valid name.")
        }
    }
}

// Function to display all grades for a single student
func displayAllGradesForStudent(grades: [[Double]]) {
    print("\nWhich student would you like to choose?")
    if let studentName = readLine()?.lowercased() {
        if let index = students.firstIndex(where: { $0.lowercased() == studentName }) {
            print("\n\(students[index])'s grades for this class are:")
            print(grades[index].map { String($0) }.joined(separator: ", "))
        } else {
            print("\nStudent does not exist. Please enter a valid name.")
        }
    }
}

// Function to display all grades for all students
func displayAllGradesForAllStudents(grades: [[Double]]) {
    for (index, studentGrades) in grades.enumerated() {
        print("\n\(students[index]) grades are: \(studentGrades.map { String($0) }.joined(separator: ", "))")
    }
}

// Function to find the average grade of the class
func findAverageGradeOfClass(grades: [[Double]]) {
    let allGrades = grades.flatMap { $0 }
    let classAverage = calculateAverage(grades: allGrades)
    print("\nThe class average is: \(String(format: "%.2f", classAverage))")
}

// Function to find the average grade of an assignment
func findAverageGradeOfAssignment(grades: [[Double]]) {
    print("\nWhich assignment would you like to get the average of (1-10)?")
    if let assignmentNumberStr = readLine(), let assignmentNumber = Int(assignmentNumberStr), assignmentNumber >= 1, assignmentNumber <= 10 {
        let assignmentGrades = grades.map { $0[assignmentNumber - 1] }
        let assignmentAverage = calculateAverage(grades: assignmentGrades)
        print("\nThe average for assignment #\(assignmentNumber) is \(String(format: "%.2f", assignmentAverage))")
    } else {
        print("\nInvalid input. Please enter a valid assignment number.")
    }
}

func changeGradeOfAssignment(grades: inout [[Double]]) {
    print("\nWhich student's grade would you like to change?")
    if let studentName = readLine()?.lowercased() {
        if let index = students.firstIndex(where: { $0.lowercased() == studentName }) {
            print("\nWhich assignment's grade would you like to change (1-10)?")
            if let assignmentNumberStr = readLine(), let assignmentNumber = Int(assignmentNumberStr), assignmentNumber >= 1, assignmentNumber <= 10 {
                print("\nEnter the new grade for \(students[index])'s assignment #\(assignmentNumber):")
                if let newGradeStr = readLine(), let newGrade = Double(newGradeStr) {
                    grades[index][assignmentNumber - 1] = newGrade
                    print("\nGrade updated successfully.")
                } else {
                    print("\nInvalid input. Please enter a valid grade.")
                }
            } else {
                print("\nInvalid input. Please enter a valid assignment number.")
            }
        } else {
            print("\nStudent does not exist. Please enter a valid name.")
        }
    }
}

// Load grades from CSV file
var grades: [[Double]] = loadGradesFromCSV()

