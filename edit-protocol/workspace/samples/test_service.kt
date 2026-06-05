package samples

data class User(
    val name: String,
    val role: String?,
    val city: String?
)

class UserFormatter {
    fun buildDisplayName(user: User): String {
        if (user.name.isBlank()) return "Anonymous"
        return user.name.trim()
    }

    fun buildAuditName(user: User): String {
        if (user.name.isBlank()) return "Anonymous"
        return "[AUDIT] ${user.name.trim()}"
    }

    fun buildLocation(user: User): String {
        if (user.city.isNullOrBlank()) return "Unknown"
        return user.city.trim()
    }
}
