Profile: CZ_ProcedurePS
Parent: Procedure
Id: cz-ProcedurePS
Title: "Procedure (CZ Patient summary)"
Description: "This profile represents the constraints applied to the Procedure resource by the CZ Patient summary project, which specifies an entry of the History of Procedure for the czech patient summary based on the FHIR standard R4."
* ^status = #active
* code 1..1 MS
* code only CodeableConceptIPS
* code from $procedures-uv-ips (preferred)
/*
* code ^slicing.discriminator.type = #pattern
* code ^slicing.discriminator.path = "$this"
* code ^slicing.description = "Discriminated by the bound value set"
* code ^slicing.rules = #open
* code ^definition = "Identification of the procedure or recording of \"absence of relevant procedures\" or of \"procedures unknown\"."
* code ^binding.extension.url = "http://hl7.org/fhir/StructureDefinition/elementdefinition-bindingName"
* code ^binding.extension.valueString = "ProcedureCode"
* code contains
    procedureGPSCode 0..1 MS and
    absentOrUnknownProcedure 0..1 MS
* code[procedureGPSCode] only CodeableConceptIPS
* code[procedureGPSCode] from $procedures-snomed-gps-uv-ips (required)
* code[procedureGPSCode] ^short = "Code for procedure from the SNOMED CT GPS code set"
* code[procedureGPSCode] ^definition = "Code for a procedure that is selected from the SNOMED CT GPS code set."
* code[procedureGPSCode] ^binding.extension.url = "http://hl7.org/fhir/StructureDefinition/elementdefinition-bindingName"
* code[procedureGPSCode] ^binding.extension.valueString = "Procedure GPS"
* code[procedureGPSCode] ^binding.description = "Codes for procedures from the SNOMED CT GPS code set"
* code[absentOrUnknownProcedure] only CodeableConceptIPS
* code[absentOrUnknownProcedure] from $absent-or-unknown-procedures-uv-ips (required)
* code[absentOrUnknownProcedure] ^short = "Code for absent problem or for unknown procedure"
* code[absentOrUnknownProcedure] ^definition = "Code representing the statement \"absent problem\" or the statement \"procedures unknown\""
* code[absentOrUnknownProcedure] ^binding.extension.url = "http://hl7.org/fhir/StructureDefinition/elementdefinition-bindingName"
* code[absentOrUnknownProcedure] ^binding.extension.valueString = "absentOrUnknownProcedure"
* code[absentOrUnknownProcedure] ^binding.description = "A code to identify absent or unknown procedures"
*/
* subject only Reference(CZ_Patient)
* subject MS
* subject ^definition = "The person on which the procedure was performed."
* subject.reference 1.. MS
* performed[x] 1..1 MS
* performed[x].extension contains $data-absent-reason named data-absent-reason 0..1 MS
* performed[x].extension[data-absent-reason] ^short = "performed[x] absence reason"
* performed[x].extension[data-absent-reason] ^definition = "Provides a reason why the performed is missing."
* asserter ^mustSupport = false
* performer ^mustSupport = false
* performer.actor only Reference(CZ_Patient or RelatedPerson or CZ_DeviceObserverPS or CZ_Practitioner or CZ_PractitionerRole or CZ_Organization)
* performer.actor ^mustSupport = false
* performer.onBehalfOf only Reference(CZ_Organization)
* performer.onBehalfOf ^mustSupport = false
* bodySite only CodeableConceptIPS
* bodySite from SNOMEDCTBodyStructures (example)
* bodySite ^binding.extension.url = "http://hl7.org/fhir/StructureDefinition/elementdefinition-bindingName"
* bodySite ^binding.extension.valueString = "BodySite"