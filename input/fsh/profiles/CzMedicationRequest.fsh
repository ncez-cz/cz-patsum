Profile: CzMedicationRequestPS
Parent: MedicationRequest
Id: cz-MedicationRequestPS
Title: "Medication Request (CZ Patient summary)"
Description: "This profile represents the constraints applied to the MedicationRequest resource by the International Patient Summary (IPS) FHIR Implementation Guide, based on FHIR R4. A record of a medication request is represented in the patient summary as an instance of a MedicationRequest resource constrained by this profile."
* ^version = "1.0.0"
* ^status = #active
* ^date = "2022-10-09T21:56:28-05:00"
* ^publisher = "Národní centrum elektronického zdravotnictví"
* ^contact.telecom.system = #url
* ^contact.telecom.value = "http://ncez.mzcr.cz"
* ^purpose = "This profile constrains the representation of a medication request related to the patient, in the context of the czech patient summary as specified by the IPS project of HL7 International."
* status ^comment = "In the scope of the IPS the entered-in-error concept is not allowed."

* medication[x] MS
/*
* medication[x] from $medication-example-uv-ips (example)
* medication[x] ^slicing.discriminator.type = #type
* medication[x] ^slicing.discriminator.path = "$this"
* medication[x] ^slicing.rules = #closed
* medication[x] ^definition = "Identifies the medication being administered. This is either a link to a resource representing the details of the medication or a simple attribute carrying a code. To improve global interoperability is strongly encouraged that the reference to a medication resource is used, limiting the usage of the medicationCodeableConcept only to the cases in which no other information than a simple code is available."
* medication[x] ^binding.description = "The type of medication"
*/
* medicationReference 0..1 MS
* medicationReference only Reference(CZ_MedicationPS)
* medicationReference ^sliceName = "medicationReference"
* medicationCodeableConcept 0..1 MS
* medicationCodeableConcept only CodeableConceptIPS
* medicationCodeableConcept ^sliceName = "medicationCodeableConcept"
* medicationCodeableConcept ^short = "Code for the medication being administered"
* medicationCodeableConcept ^definition = "Code for the medication being administered."
* subject only Reference(CZ_Patient)
* subject MS
* subject.reference 1.. MS
* dosageInstruction MS
* dosageInstruction.text MS
* dosageInstruction.timing MS
* dosageInstruction.route only CodeableConceptIPS
* dosageInstruction.route from $medicine-route-of-administration (preferred)
* dosageInstruction.route ^binding.description = "EDQM Standards Terms"
* dispenseRequest.validityPeriod 1..
* dispenseRequest.validityPeriod.extension contains $data-absent-reason named data-absent-reason 0..1
* dispenseRequest.validityPeriod.extension[data-absent-reason] ^short = "validityPeriod absence reason"
* dispenseRequest.validityPeriod.extension[data-absent-reason] ^definition = "Provides a reason why the validityPeriod is missing."