import '../../../features/CRM/models/customer_model.dart';
import '../../repositories/CRM/customer_repository.dart';

/*
********************************************************************************
OBJECTIVE:
- DAO is a thin wrapper around repository.
- The Controller/Notifier can use DAO instead of directly hitting Firebase.
********************************************************************************
*/

class CustomerDAO {
  final CustomerRepository _repo = CustomerRepository();

  Future<List<Customer>> getAllCustomers() async {
    return await _repo.fetchAllCustomers();
  }

  Future<Customer?> getCustomerById(String custID) async {
    return await _repo.fetchCustomerById(custID);
  }

  Future<void> addCustomer(Customer customer) async {
    await _repo.addCustomer(customer);
  }

  Future<void> updateCustomer(Customer customer) async {
    await _repo.updateCustomer(customer);
  }

  Future<void> deleteCustomer(String custID) async {
    await _repo.deleteCustomer(custID);
  }
}
