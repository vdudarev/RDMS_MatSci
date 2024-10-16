namespace WebUtilsLib;

public struct UserContext {
    public int userId;
    public bool isAdmin;
    public AccessControl access;
    public bool userCanAdd;

    public UserContext(int userId, bool isAdmin, bool userCanAdd, AccessControl access) {
        this.userId = userId;
        this.isAdmin = isAdmin;
        this.userCanAdd = userCanAdd;
        this.access = access;
    }
}
